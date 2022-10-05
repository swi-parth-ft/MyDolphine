//
//  GuideViewController.swift
//  Rhythm
//
//  Created by Parth Antala on 2022-07-22.
//

import UIKit

class GuideViewController: UIPageViewController {

    lazy var vcList:[UIViewController] = {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let firstVC = storyboard.instantiateViewController(identifier: "guide1")
            let secondVC = storyboard.instantiateViewController(identifier: "guide2")
            let thirdVC = storyboard.instantiateViewController(identifier: "guide3")
              
            return [firstVC, secondVC, thirdVC]
              
        }()
      
      
        override func viewDidLoad() {
            super.viewDidLoad()
            var appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
            appearance.pageIndicatorTintColor = UIColor.gray
            appearance.currentPageIndicatorTintColor = UIColor.red
            // Do any additional setup after loading the view.
            self.dataSource = self
            if let vc = vcList.first{
                self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            }
              
        }
}
    extension GuideViewController : UIPageViewControllerDataSource{
          
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
                guard let index = vcList.lastIndex(of: viewController) else { return nil }
                let previousIndex = index - 1
                guard previousIndex >= 0 else {return nil}
                guard previousIndex < vcList.count else {return nil}
                return vcList[previousIndex]
                  
            }
            func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = vcList.lastIndex(of: viewController) else { return nil }
                let previousIndex = index + 1
                guard previousIndex >= 0 else {return nil}
                guard previousIndex < vcList.count else {return nil}
                return vcList[previousIndex]
            }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


