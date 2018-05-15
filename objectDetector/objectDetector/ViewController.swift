//
//  ViewController.swift
//  objectDetector
//
//  Created by Sanjay Kumawat on 10/13/17.
//  Copyright © 2017 internclabs. All rights reserved.
//

import UIKit
import AVKit
import Vision
class ViewController: UIViewController {
	
	@IBOutlet weak var lbl: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setCameraInputAndOutput()
	}
	
	func setCameraInputAndOutput() {
		let captureSession =  AVCaptureSession()
		captureSession.sessionPreset = .photo
		guard let captureDevice = AVCaptureDevice.default(for: .video) else {
			return
		}
		guard let input = try?  AVCaptureDeviceInput(device: captureDevice) else {
			return
		}
		captureSession.addInput(input )
		captureSession.startRunning()
		
		let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = view.frame
		view.layer.addSublayer(previewLayer)
		let cameraOutput = AVCaptureVideoDataOutput()
		cameraOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
		captureSession.addOutput(cameraOutput)
		
		
	}
}
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
			return
		}
		guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
			return
		}
		let request = VNCoreMLRequest(model: model) { (finishReq, error) in
			guard let results = finishReq.results as? [VNClassificationObservation] else {
				return
			}
			guard let firstObservation = results.first else {
				return
			}
			print(firstObservation.identifier, firstObservation.confidence)
			DispatchQueue.main.async {
				self.lbl.text = "\(firstObservation.identifier)"
			}
		}
		try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
	}
}

