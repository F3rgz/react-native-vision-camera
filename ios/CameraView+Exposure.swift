//
//  CameraView+Exposure.swift
//  VisionCamera
//
//  Created by Fergal Eccles on 09/08/2023.
//

import Foundation

extension CameraView {
	func updateExposureSettings(iso: NSNumber, promise: Promise) {
		withPromise(promise) {
			guard let device = self.videoDeviceInput?.device else {
				throw CameraError.session(SessionError.cameraNotReady)
			}
			
			print("You made it!")
			print(iso)
			return nil
		}
	}
}
