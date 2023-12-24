//
//  RTCustomAlert.swift
//  RTCustomAlert
//
//  Created by Rohit on 19/10/20.
//

import UIKit

protocol RTCustomAlertDelegate: AnyObject {
    func onClickSubmit(_ alert: RTCustomAlert, alertTag: Int)
}
class RTCustomAlert: UIViewController {

    @IBOutlet weak var submitRequestView: UIView!
    @IBOutlet weak var receivedRequestView: UIView!
    @IBOutlet weak var parkView: UIView!
    
    var viewType : Int = 0
    var alertTag = 0
    
    weak var delegate: RTCustomAlertDelegate?
    private var dismissViewTap: UITapGestureRecognizer?

    init() {
        super.init(nibName: "RTCustomAlert", bundle: Bundle(for: RTCustomAlert.self))
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.submitRequestView.isHidden = true
        self.receivedRequestView.isHidden = true
        self.parkView.isHidden = true


        dismissViewTap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        
        if(self.alertTag == 0){
            self.submitRequestView.isHidden = false
        }
        else  if(self.alertTag == 1){
            self.receivedRequestView.isHidden = false
        }
        else  if(self.alertTag == 2){
            self.parkView.isHidden = false
        }
    }
    
    @IBAction func requestButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.onClickSubmit(self, alertTag: alertTag)
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true, completion: nil)
        delegate?.onClickSubmit(self, alertTag: alertTag)

        }
    
    func show() {
        if #available(iOS 13, *) {
            UIApplication.shared.windows.first?.rootViewController?.present(self, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController!.present(self, animated: true, completion: nil)
        }
    }
    
   
    @IBAction func  onClickSubmit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.onClickSubmit(self, alertTag: alertTag)
    }
   
}
