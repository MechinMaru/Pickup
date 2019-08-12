//
//  PickupViewController.swift
//  Pickup
//
//  Created by MECHIN on 8/9/19.
//  Copyright © 2019 mechin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PickupViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var currentLocationBarButtonItem: UIBarButtonItem!
    
    private lazy var viewModel: PickupViewModelType = {
      return PickupViewModel()
    }()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindOutputs()
        bindInputs()
        viewModel.input.vieWDidLoadTrigger.accept(())
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "PickupTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PickupTableViewCell.cellIdentifier)
    }
    
    private func bindInputs() {
        currentLocationBarButtonItem.rx.tap.asDriver()
            .drive(onNext: viewModel.input.locationButtonTrigger.accept)
            .disposed(by: disposeBag)
    }
    
    private func bindOutputs() {
        viewModel.output.isLoading
            .drive(UIApplication.shared.rx.isNetworkIndicatorAnimated)
            .disposed(by: disposeBag)
        
        viewModel.output.pickupDataSource
            .drive(tableView.rx.items) { [weak self] (tableView, index, item) in
                let indexPath = IndexPath(row: index, section: 0)
                let cell: PickupTableViewCell = tableView.dequeueReusableCell(withIdentifier: PickupTableViewCell.cellIdentifier, for: indexPath) as! PickupTableViewCell                
                cell.configureLayoutWith(item)
                cell.pickupButton.rx.tap.asDriver().drive(onNext: { [weak self] (_) in
                    self?.viewModel.input.onSelectedPickupItemWithId.accept(item.data.pickupLocationId)
                })
                .disposed(by: cell.disposeBag)
                
                return cell
            }
            .disposed(by: disposeBag)
        
        viewModel.output.onRequestShowAlert
            .drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.showAlert()
            })
            .disposed(by: disposeBag)
        
        viewModel.output.onRequestShowAPIError
            .drive(onNext: { [weak self] (error) in
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    private func showAlert() {
        let alertController = UIAlertController(title: "Turn on location services to allow \"Pickup\" to determine your location.", message: "", preferredStyle: .alert)
        let settingAction = UIAlertAction(title: "Setting", style: .default) { (alertAction) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
