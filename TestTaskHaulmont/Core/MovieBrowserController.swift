
import UIKit
import CoreData

protocol MovieControllerDelegate: AnyObject{
    func didTapButtonProfile()
}

class MovieBrowserController: UICollectionViewController{

    // MARK: - Properties
    var delegate: MovieControllerDelegate?
    
    init() {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            super.init(collectionViewLayout: layout)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let infoView: InfoView = {
        let view = InfoView()
        view.layer.cornerRadius = 5
        return view
    }()
    
    let visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    let networking = requestFromTMDb()
    var results: MoviesData!
    
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jsonRequest()
        configureViewComponents()
        configurateNavBar()
    }

    // MARK: - API
    private func jsonRequest() {
     networking.jsonRequest { [weak self] result in
          switch result {
          case .success(let re):
              self?.results = re
              self?.collectionView.reloadData()
          case .failure(let error):
              print(error.localizedDescription)
          }
      }
}

    //MARK: - Configurate NavigationBar
    private func configurateNavBar() {
        collectionView.backgroundColor = .background()
        self.title = "Movie Browser"
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.text()]
        navigationItem.standardAppearance = appearance
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:
                                                    UIImage(systemName: "magnifyingglass"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(toSearchButtonTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:
                                                           UIImage(named: "user"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(barButtonTapped))
    }
    
    //MARK: - Selectors
    @objc func barButtonTapped() {
        delegate?.didTapButtonProfile()
        
    }
    
    @objc func toSearchButtonTapped() {
        let searchVC =  SearchMovieViewController()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
   
    @objc func handleDismissal() {
        dismissInfoView()
    }
    
    //MARK: - setup InfoView
    private func setInfoView() {
        view.addSubview(infoView)
        infoView.configureViewComponents()
    
        infoView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width - 34, height: 650)
        infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        infoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        infoView.alpha = 1
        
        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.alpha = 0.6
            self.infoView.alpha = 1
            self.infoView.transform = .identity
        }
    }
    
    //MARK: - Dismiss InfoView
    private func dismissInfoView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.visualEffectView.alpha = 0
            self.infoView.alpha = 0
            self.infoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (_) in
            self.infoView.removeFromSuperview()
        }
    }
    
    //MARK: - set VisualEffect, dismissGesture, colletionRegister
    private func configureViewComponents() {
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.reuseId)
        
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        visualEffectView.alpha = 0
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        let gestureTwo = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        infoView.exitButton.addGestureRecognizer(gesture)
        visualEffectView.addGestureRecognizer(gestureTwo)
    }
}

// MARK: - UICollectionViewDataSource/Delegate
extension MovieBrowserController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results?.movies.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseId, for: indexPath) as! CollectionViewCell
        let results = results?.movies[indexPath.row]
        cell.setupOnCell(results!)
        cell.backgroundColor = .buttonB()
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setInfoView()
        let results = results.movies[indexPath.row]
        infoView.setupOnCell(results)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MovieBrowserController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (view.frame.size.width/2)-0.5,
                      height: (view.frame.size.width/1.3)-9)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}