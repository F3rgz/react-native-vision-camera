//
//  CameraView+Exposure.swift
//  VisionCamera
//
//  Created by Fergal Eccles on 09/08/2023.
//

import Foundation
import AVFoundation

extension CameraView {
	func updateExposureSettings(iso: NSString, promise: Promise) {
		withPromise(promise) {
			guard let device = self.videoDeviceInput?.device else {
				throw CameraError.session(SessionError.cameraNotReady)
			}
			
			guard let device = self.videoDeviceInput?.device else {
				throw CameraError.session(SessionError.cameraNotReady)
			}
			if !device.isExposureModeSupported(.custom) {
				throw CameraError.device(DeviceError.customExposureNotSupported)
			}
			
			do {
				try device.lockForConfiguration()
				
				if (iso == "auto") {
					print("setting auto")
					self.fixedISO = false
					device.exposureMode = .continuousAutoExposure
				} else {
					print("setting fixed iso")
					print(iso)
					self.fixedISO = true
					device.exposureMode = .custom
					device.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: Float(iso.doubleValue))
				}
				
				device.unlockForConfiguration()
			} catch {
				throw CameraError.device(DeviceError.configureError)
			}
			
			return nil
		}
	}
}
