
//
//  ContainerUnit.swift
//  Compose
//
//  Created by Bruno Bilescky on 26/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

protocol ContainerUnit: ComposingUnit {

    func scrollviewFrom(view: UIView)-> UIScrollView
    
}
