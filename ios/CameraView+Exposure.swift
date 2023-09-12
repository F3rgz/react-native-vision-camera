//
//  CameraView+Exposure.swift
//  VisionCamera
//
//  Created by Fergal Eccles on 09/08/2023.
//

import Foundation
import AVFoundation

extension CameraView {
	func updateExposureSettings(iso: NSString, exposureDuration: NSString, promise: Promise) {
		withPromise(promise) {
			guard let device = self.videoDeviceInput?.device else {
				throw CameraError.session(SessionError.cameraNotReady)
			}
			if !device.isExposureModeSupported(.custom) {
				throw CameraError.device(DeviceError.customExposureNotSupported)
			}
			
			do {
				try device.lockForConfiguration()
				
				self.fixedISO = iso != "auto"
				self.fixedExposureDuration = exposureDuration != "auto"
				
				if (self.fixedISO || self.fixedExposureDuration) {
					device.exposureMode = .custom
					
					let durationValue = self.fixedExposureDuration ? CMTimeMake(value: 1, timescale: exposureDuration.intValue) : AVCaptureDevice.currentExposureDuration
					let isoValue = self.fixedISO ? Float(iso.doubleValue) : AVCaptureDevice.currentISO
					
					device.setExposureModeCustom(duration: durationValue, iso: isoValue)
					
					// TODO: Set up function to auto-set values if either iso or exposure have been fixed
				} else {
					device.exposureMode = .continuousAutoExposure
				}
				
				device.unlockForConfiguration()
			} catch {
				throw CameraError.device(DeviceError.configureError)
			}
			
			return nil
		}
	}
	
	public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

		guard let key = keyPath else {
				print("Not calling")
				return
		}
		
		guard let device: AVCaptureDevice = videoDeviceInput?.device else {
			invokeOnError(.session(.cameraNotReady))
			return
		}
		
		if key == "exposureTargetOffset" {
			let body: NSDictionary = [
				"iso": device.iso,
				"aperture": device.lensAperture,
				"evOffset": device.exposureTargetOffset,
				"exposureDuration": device.exposureDuration.seconds,
				"lensPosition": device.lensPosition,
				"minExposureTargetBias": device.minExposureTargetBias,
				"maxExposureTargetBias": device.maxExposureTargetBias,
				"exposureTargetBias": device.exposureTargetBias
			]
			
			CameraEventEmitter.emitter.sendEvent(withName: "onChanged", body: body)
		}
	}
}
