//
//  ViewController.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 30.12.17.
//  Copyright © 2017 Markus Gnadl. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    var puzzleIdentifier: String? = nil
    var puzzleCategory: String? = nil
    
    var debug = false
    
    var puzzle: Puzzle! {
        didSet {
            puzzleIdentifier = puzzle.identifier
            puzzleCategory = puzzle.category
            
            scrollView.zoomScale = 1.0
            crosswordView.puzzle = puzzle
            self.questionLabel.text = ""
            titleView.text = puzzle.crossWordTitle
            self.numMode = (puzzle.inputType == .numeric)
            undoManager?.removeAllActions()
        }
    }
    
    @IBOutlet var titleView: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var crosswordView: CrosswordView!
    @IBOutlet var questionLabel: UILabel!
    
    @IBAction func save(sender: AnyObject){
        crosswordView.save(sender: sender)
    }
    
    @IBAction func clear(sender: AnyObject){
        crosswordView.clear(sender: sender)
    }
    
    @IBAction func undo(sender: AnyObject){
        undoManager?.undo()
    }
    
    @IBAction func check(sender: AnyObject){
        crosswordView.markWrongCells()
    }
    
    @objc func strikeWord() {
        //currentCellsHighlighted.forEach{ $0.content = ""}
    }
    
    
    var strikeThroughGestureRecognizer = StrikeThroughGestureRecognizer()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMlModel()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        questionLabel.text = ""
        
        scrollView.contentSize = crosswordView.frame.size
        let enableGesture = false

        crosswordView.addGestureRecognizer(strikeThroughGestureRecognizer)
        strikeThroughGestureRecognizer.addTarget( self, action: #selector(strikeWord))
    
        //display current word hint
        crosswordView.hintClosures.append {c in
            self.questionLabel.attributedText = c
        }
        
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2 //pan with two finger only
        
        
        let cgView = StrokeCGView(frame: crosswordView.frame)
        self.cgView = cgView
        self.cgView.isUserInteractionEnabled = false
        self.cgView.backgroundColor = UIColor.clear
        view.addSubview(cgView)
        
        let fingerStrokeRecognizer = LetterGestureRecognizer(target: self, action: #selector(strokeUpdated(_:)))
        fingerStrokeRecognizer.delegate = self
        fingerStrokeRecognizer.cancelsTouchesInView = false
        fingerStrokeRecognizer.coordinateSpaceView = crosswordView
        fingerStrokeRecognizer.isForPencil = false
        crosswordView.addGestureRecognizer(fingerStrokeRecognizer)
        
        let configurations = [
            { self.cgView.displayOptions = .calligraphy },
            { self.cgView.displayOptions = .ink },
            { self.cgView.displayOptions = .debug },
        ]
        configurations.last?() //last as default
    }
    
    override func viewDidLayoutSubviews() {
        // calc minimum zoomScale
        let zoomHor = self.scrollView.frame.size.width / self.contentView.frame.size.width
        let zoomVer = self.scrollView.frame.size.height / self.contentView.frame.size.height
        let zoomMin = min(zoomHor, zoomVer)
        self.scrollView.minimumZoomScale = min(zoomMin, 1.0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Stroke Debug
    var cgView: StrokeCGView!
    
    
    @objc func strokeUpdated(_ strokeGesture: LetterGestureRecognizer) {
        
        
        if debug == true { //display stroke
            cgView.strokeCollection = strokeGesture.strokeCollection
        }
        
        
        let boundingSquare = self.numMode ? strokeGesture.strokeCollection.squareBoundingRect(insetRatio: 0.6) : strokeGesture.strokeCollection.squareBoundingRect()
        
        let size = boundingSquare.size //CGSize(width:32,height:32)
        let drawingOffsetVec = boundingSquare.origin - CGPoint.zero
        
        
        
        
        UIGraphicsBeginImageContextWithOptions( size , true, 1.0)
        
        self.numMode ? UIColor.black.set() : UIColor.white.set()
        
        UIRectFill(CGRect(origin: CGPoint(x: 0, y: 0), size: size ))
        
        self.numMode ? UIColor.white.set() : UIColor.black.set()
        
        
        for stroke in strokeGesture.strokeCollection.strokes {
            let path = UIBezierPath()
            path.lineWidth = size.width / 16.0
            var first = true
            for sample in stroke.samples {
                if first {
                    first = false
                    path.move(to: (sample.location - drawingOffsetVec))
                }
                else {
                    path.addLine(to: sample.location - drawingOffsetVec)
                }
            }
            path.stroke()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //debug
        //imgView.image  = image
        
        var possibilities: [String]? = nil
        
        if self.numMode {
            //no zero needed
            possibilities = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
        }
        else {
            let numberOfStrokes = strokeGesture.strokeCollection.strokes.count
            if(numberOfStrokes == 1){
                let possibleOneStrokeLetters = ["C","G","I","J","L","M","N","O","S","U","V","W","Z"];
                possibilities = possibleOneStrokeLetters
            }
        }
        
        if let image = image {
            classifyImage(image: image, constrainingSet: possibilities)
        }
        
        //consumed
        strokeGesture.strokeCollection = StrokeCollection()
    }
    
    
    
    
    //MARK: CoreML Model
    var numMode = false
    var s: String = ""
    
    var alphaModel: VNCoreMLModel!
    var numModel:   VNCoreMLModel!
    
    private func loadMlModel() {
        do{
            let a = try mnist_alpha(configuration: MLModelConfiguration()).model
            let b = try mnist_num(configuration: MLModelConfiguration()).model
            
            alphaModel = try? VNCoreMLModel(for: a)
            numModel   = try? VNCoreMLModel(for: b)
        }
        catch {
            
        }
    }
    
    func showDetectedText() {
        crosswordView.inputCharAndAdvance(char: s)
    }
    
    
    func handleResult(_ result: String) {
        objc_sync_enter(self)
        s = result
        objc_sync_exit(self)
        DispatchQueue.main.async {
            self.showDetectedText()
        }
    }
    
    func classifyImage(image: UIImage, constrainingSet: [String]? = nil) {
        
        
        let model: VNCoreMLModel = self.numMode ? self.numModel : self.alphaModel
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Unexpected result type from VNCoreMLRequest")
            }
            for c in results {
                let c = c.identifier
                if let contained = constrainingSet?.contains(c) {
                    if contained {
                        self?.handleResult(c)
                        break
                    }
                }
                else {
                    //no set to check against
                    self?.handleResult(c)
                    break
                }
                
            }
            
            
        }
        guard let ciImage = CIImage(image: image) else {
            fatalError("Could not convert UIImage to CIImage :(")
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            }
            catch {
                print(error)
            }
        }
    }
    
    
    //MARK: State Restoration
    let puzzleCategoryKey = "puzzleCategory"
    let puzzleIdentifierKey = "puzzleIdentifier"
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(puzzleCategory,   forKey: self.puzzleCategoryKey)
        coder.encode(puzzleIdentifier, forKey: self.puzzleIdentifierKey)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        puzzleCategory   = coder.decodeObject(forKey: self.puzzleCategoryKey) as? String
        puzzleIdentifier = coder.decodeObject(forKey: self.puzzleIdentifierKey ) as? String
        
        guard let puzzleIdentifier = puzzleIdentifier else {
            return
        }
        guard let puzzleCategory = puzzleCategory else {
            return
        }
        if let puzzle = PuzzleManager.sharedInstance.puzzles[puzzleCategory]![puzzleIdentifier] {
            self.puzzle = puzzle
        }
    }
}


extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //true by default
        return true
    }
    
    // We want the pencil to recognize simultaniously with all others.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //default
        return false
    }
}

extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let popOver = segue.destination.popoverPresentationController {
            if let anchor  = popOver.sourceView {
                popOver.sourceRect = anchor.bounds
            }
        }
    }
}

extension ViewController : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}
