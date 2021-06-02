//
//
//  Workspace: ScrollView
//  MacOS Version: 11.4
//			
//  File Name: ScrollViewController.swift
//  Creation: 6/2/21 12:17 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit
import os

public class ScrollViewController: UIViewController
{
    // MARK: - Initialization
    
    public static var s_LoggerSubsystem: String = Bundle.main.bundleIdentifier!
    public static var s_LoggerCategory: String = "ScrollViewController"
    public static var s_Logger: Logger = .init(subsystem: s_LoggerSubsystem, category: s_LoggerCategory)
    
    public private(set) var currentControllers: [UIViewController]
    public private(set) var collectionView: UICollectionView!
    public private(set) var collectionViewLayout: UICollectionViewFlowLayout!
    
    /// The number of items in the specified section.
    public var numberOfItemsInSection: Int = 1
    
    /// The margins to apply to content in the specified section.
    public var sectionInset: UIEdgeInsets = .zero
    
    /// The spacing between successive rows or columns of a section.
    public var minimumLineSpacing: CGFloat = .zero
    
    /// The spacing between successive items in the rows or columns of a section.
    public var minimumInteritemSpacing: CGFloat = .zero
    
    /// The mimimum number of controllers left to display before not having anymore.
    public var minimumControllersLeftBeforeEnd: Int = 3
    
    /// Action called when the collection view has trigger refresh.
    public var onRefreshAction: (_ completion: @escaping () -> Void) -> Void = { completion in completion() }
    
    /// Action called when the collection view has reached the minimumControllersLeftBeforeEnd.
    public var onDidAlmostReachEnd: () -> Void = { }
    
    private var m_ScrollDirection: UICollectionView.ScrollDirection = .vertical
    private var m_IsPagedEnabled: Bool = true
    private var m_CellId: String = "ScrollViewControllerCellId"
    
    /// - Parameter  controllers: The controllers in collection, in order.
    public init(scrollDirection: UICollectionView.ScrollDirection = .vertical, isPagingEnabled: Bool = true, controllers: [UIViewController])
    {
        m_ScrollDirection = scrollDirection
        m_IsPagedEnabled = isPagingEnabled
        currentControllers = controllers
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        currentControllers = []
        
        super.init(coder: coder)
    }
}

public extension ScrollViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configure()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark
        {
            collectionView.backgroundColor = .black
        }
        else
        {
            collectionView.backgroundColor = .white
        }
    }
}

public extension ScrollViewController
{
    
    /// Updates the controllers with new array.
    func updateControllers(newControllers: [UIViewController])
    {
        ScrollViewController.s_Logger.debug("Updating controllers.")
        
        currentControllers = newControllers
        collectionView.reloadData()
    }
    
    /// Adding the given controllers to the existing ones.
    func addControllers(addedControllers: [UIViewController])
    {
        ScrollViewController.s_Logger.debug("Adding controllers.")
        
        currentControllers.append(contentsOf: addedControllers)
        collectionView.reloadData()
    }
    
    func scrollToTop()
    {
        collectionView.setContentOffset(.zero, animated: true)
    }
}

extension ScrollViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return numberOfItemsInSection
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return Int(Double(currentControllers.count / numberOfItemsInSection).rounded(.up))
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        guard let controller = getControllerFor(indexPath: indexPath) else { return }
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(controller)
        cell.addSubview(controller.view)
        
        NSLayoutConstraint.activate(
            [
                controller.view.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
                controller.view.topAnchor.constraint(equalTo: cell.topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: cell.bottomAnchor)
            ]
        )
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        defer
        {
            fetchNewControllersIfNeededAt(indexPath: indexPath)
        }
        
        guard let controller = getControllerFor(indexPath: indexPath) else { return }
        
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: m_CellId, for: indexPath)
        
        cell.backgroundColor = .clear
        cell.clipsToBounds = true
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return minimumLineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return minimumInteritemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return getItemSize()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return sectionInset
    }
}

private extension ScrollViewController
{
    // MARK: - Configuration
    
    func configure()
    {
        configureCollectionViewLayout()
        configureCollectionView()
        configureRefreshControl()
    }
    
    func configureCollectionViewLayout()
    {
        collectionViewLayout = .init()
        
        collectionViewLayout.minimumInteritemSpacing = minimumInteritemSpacing
        collectionViewLayout.minimumLineSpacing = minimumLineSpacing
        collectionViewLayout.estimatedItemSize = .zero
        collectionViewLayout.scrollDirection = m_ScrollDirection
    }
    
    func configureCollectionView()
    {
        collectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = m_IsPagedEnabled
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.alwaysBounceVertical = m_ScrollDirection == .vertical
        collectionView.alwaysBounceHorizontal = m_ScrollDirection == .horizontal
        
        if traitCollection.userInterfaceStyle == .dark
        {
            collectionView.backgroundColor = .black
        }
        else
        {
            collectionView.backgroundColor = .white
        }
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate(
            [
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
        
        ScrollViewController.s_Logger.debug("Registering collection view.")
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: m_CellId)
    }
    
    func configureRefreshControl()
    {
        let refreshControl = UIRefreshControl()
        
        refreshControl.attributedTitle = nil
        refreshControl.translatesAutoresizingMaskIntoConstraints = false
        refreshControl.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
        refreshControl.transform = .init(scaleX: 0.7, y: 0.7)
        
        collectionView.refreshControl = refreshControl
    }
}

private extension ScrollViewController
{
    // MARK: - Updates
    
    @objc func didRefresh()
    {
        ScrollViewController.s_Logger.debug("Start refreshing.")
        
        DispatchQueue.main.async
        { [weak self] in
            self?.onRefreshAction
            {
                self?.collectionView.refreshControl?.endRefreshing()
                
                ScrollViewController.s_Logger.debug("End refreshing.")
            }
        }
    }
}

private extension ScrollViewController
{
    func fetchNewControllersIfNeededAt(indexPath: IndexPath)
    {
        let currentControllerIndex = getControllerIndexFor(indexPath: indexPath)
        let maxControllerIndex = currentControllers.count - 1
        let remainingControllers = maxControllerIndex - currentControllerIndex
        
        if  remainingControllers <= minimumControllersLeftBeforeEnd
        {
            ScrollViewController.s_Logger.debug("Remaining controllers '\(remainingControllers)'.")
            
            DispatchQueue.main.async
            { [weak self] in
                self?.onDidAlmostReachEnd()
            }
        }
    }
    
    func getControllerIndexFor(indexPath: IndexPath) -> Int
    {
        return indexPath.section * numberOfItemsInSection + indexPath.row
    }
    
    func getControllerFor(indexPath: IndexPath) -> UIViewController?
    {
        let index = getControllerIndexFor(indexPath: indexPath)
        
        if currentControllers.count - 1 >= index
        {
            return currentControllers[index]
        }
        
        ScrollViewController.s_Logger.error("Failed to get controller for index path.")
        
        return nil
    }
    
    func getItemSize() -> CGSize
    {
        let numberOfItemsInSection = CGFloat(numberOfItemsInSection)
        let horizontalInsetSize = sectionInset.left + sectionInset.right + (numberOfItemsInSection - 1) * minimumLineSpacing + (m_ScrollDirection == .vertical ? (numberOfItemsInSection - 1) * minimumInteritemSpacing : 0)
        let width = (view.frame.size.width - horizontalInsetSize) / numberOfItemsInSection
        let verticalInsetSize = sectionInset.top + sectionInset.bottom + (m_ScrollDirection == .horizontal ? minimumInteritemSpacing : 0)
        let height = view.frame.size.height - verticalInsetSize
        let itemSize: CGSize = .init(width: width, height: height)
        
        return itemSize
    }
}

