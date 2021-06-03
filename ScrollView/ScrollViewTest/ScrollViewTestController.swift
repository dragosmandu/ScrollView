//
//
//  Workspace: ScrollView
//  MacOS Version: 11.4
//			
//  File Name: ScrollViewTestController.swift
//  Creation: 6/2/21 12:23 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit
import ScrollView

class ScrollViewTestController: UIViewController
{
    private let m_ScrolViewController: ScrollViewController = .init(scrollDirection: .vertical, isPagingEnabled: true, controllers: [])
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        m_ScrolViewController.view.translatesAutoresizingMaskIntoConstraints = false
        m_ScrolViewController.onRefreshAction = onRefreshAction
        m_ScrolViewController.onDidAlmostReachEnd = onDidAlmostReachEnd
        m_ScrolViewController.numberOfRowsOrColumns = 3
        m_ScrolViewController.numberOfItemsInSection = 5
        m_ScrolViewController.sectionInset = .init(top: 5, left: 10, bottom: 5, right: 10)
        m_ScrolViewController.minimumInteritemSpacing = 10
        
        addChild(m_ScrolViewController)
        view.addSubview(m_ScrolViewController.view)
        
        NSLayoutConstraint.activate(
            [
                m_ScrolViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
                m_ScrolViewController.view.heightAnchor.constraint(equalToConstant: 500),
                m_ScrolViewController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
        
        m_ScrolViewController.updateControllers(newControllers: createNewControllers())
    }
    
    private func onDidAlmostReachEnd()
    {
        let newControllers = createNewControllers()
        
        m_ScrolViewController.addControllers(addedControllers: newControllers)
    }
    
    private func onRefreshAction(_ completion: @escaping () -> Void)
    {
        for (i, controller) in m_ScrolViewController.currentControllers.enumerated()
        {
            for subview in controller.view.subviews
            {
                if let label = subview as? UILabel
                {
                    label.text = "\(i) / \(m_ScrolViewController.currentControllers.count - 1) R"
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3)
        {
            completion()
        }
    }
    
    private func createNewControllers() -> [UIViewController]
    {
        let numNewControllers = 50
        var controllers: [UIViewController] = []
        var begin = m_ScrolViewController.currentControllers.count - 1
        let end = m_ScrolViewController.currentControllers.count + numNewControllers
        
        if begin == -1 { begin = 0 }
        
        for i in begin...end
        {
            let controller = UIViewController()
            let label = UILabel()
            
            controller.view.backgroundColor = .yellow
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "\(i) / \(m_ScrolViewController.currentControllers.count + numNewControllers)"
            label.textColor = .black
            
            controller.view.addSubview(label)
            
            NSLayoutConstraint.activate(
                [
                    label.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
                ]
            )
            
            controllers.append(controller)
        }
        
        return controllers
    }
}
