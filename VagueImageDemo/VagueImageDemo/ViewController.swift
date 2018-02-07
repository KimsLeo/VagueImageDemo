//
//  ViewController.swift
//  VagueImageDemo
//
//  Created by win on 2018/2/7.
//  Copyright © 2018年 win. All rights reserved.
//

import UIKit


typealias Filter = (CIImage) -> CIImage

func blur(radius: Double) -> Filter {
    return { image in
    let parameters: [String: Any] = [ kCIInputRadiusKey: radius, kCIInputImageKey: image
    ]
    guard let  lter = CIFilter (name: "CIGaussianBlur",
                                withInputParameters: parameters)
        else { fatalError () }
    guard let outputImage =  lter.outputImage
        else { fatalError () }
        return outputImage
    }
    
}


func generate(color:UIColor)-> Filter {
    return { _ in
    let parameters = [kCIInputColorKey: CIColor(cgColor: color.cgColor)]
    guard let  filter = CIFilter (name: "CIConstantColorGenerator",
                                                                                                     withInputParameters: parameters)
        else { fatalError () }
    guard let outputImage =  filter.outputImage
        else { fatalError () }
        return outputImage
    }
    
}

func compose( filter  filter1: @escaping Filter, with  filter2 : @escaping Filter) -> Filter
{
    return { image in  filter2 (  filter1 (image)) }
}

func compositeSourceOver(overlay: CIImage) -> Filter {
    return { image in
    let parameters = [ kCIInputBackgroundImageKey: image, kCIInputImageKey: overlay
    ]
    guard let  filter = CIFilter (name: "CISourceOverCompositing",
                                withInputParameters: parameters)
        else { fatalError () }
    guard let outputImage =  filter.outputImage
        else { fatalError () }
    return outputImage.cropped(to: image.extent)
    }
}

func overlay(color: UIColor) -> Filter {
    return { image in
    let overlay = generate(color: color)(image).cropped(to: image.extent)
    return compositeSourceOver(overlay: overlay)(image)
    }
}




class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        guard let img = UIImage(named:"1-960x1704") else {
            fatalError()
        }
        guard let image = CIImage(image: img) else{
            fatalError()
        }
        let radius = 1.0
        let color = UIColor.white.withAlphaComponent(0.4)
        
        let overlaidImage =  compose(filter: blur(radius: radius), with: overlay(color: color))(image)
        
        let imageView = self.setImageViewFrame(imageView: self.createImageView(name: "2-960x1704"))
        self.view.addSubview(imageView)
        
        imageView.image = UIImage(ciImage: overlaidImage)
        
    }

    private func createImageView(name: String) -> UIImageView{
        let imageview = UIImageView(image: UIImage(named:name))
        return imageview
    }
    
    private func setImageViewFrame(imageView: UIImageView) -> UIImageView{
        imageView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        return imageView
    }


}

