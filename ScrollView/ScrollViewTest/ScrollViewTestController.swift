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
        
        view.backgroundColor = .white
        
        m_ScrolViewController.view.translatesAutoresizingMaskIntoConstraints = false
        m_ScrolViewController.onRefreshAction = onRefreshAction
        m_ScrolViewController.onDidAlmostReachEnd = onDidAlmostReachEnd
        
        
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
                    label.text = "Controller index: \(i) / \(m_ScrolViewController.currentControllers.count - 1) Refreshed"
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
        var controllers: [UIViewController] = []
        var begin = m_ScrolViewController.currentControllers.count - 1
        let end = m_ScrolViewController.currentControllers.count + 3
        
        if begin == -1 { begin = 0 }
        
        for i in begin...end
        {
            let controller = UIViewController()
            let label = UILabel()
            
            controller.view.backgroundColor = .yellow
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Controller index: \(i) / \(m_ScrolViewController.currentControllers.count + 3)"
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
