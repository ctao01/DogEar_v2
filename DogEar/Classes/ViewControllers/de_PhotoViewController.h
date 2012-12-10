//
//  de_PhotoViewController.h
//  DogEar
//
//  Created by Joy Tao on 11/27/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

/* JT-TODO:
    - Edit Photo Features: Rotate,Crop,Auto Enhance
 
 */

#import <UIKit/UIKit.h>

//typedef enum {
//    BKToolBarTypeEditing,
//    BKToolBarTypeViewing
//}BKToolBarType;

@interface de_PhotoViewController : UIViewController <UIActionSheetDelegate , UIAlertViewDelegate , UIPrintInteractionControllerDelegate , UIScrollViewDelegate>
{
    bool isTappedInCropView;
	bool isTappedOnUpperLeftCorner;
	bool isTappedOnUpperRightCorner;
	bool isTappedOnLowerLeftCorner;
	bool isTappedOnLowerRightCorner;
}
//- (id) initWithImage:(UIImage*)image toolBarType:(BKToolBarType)toolBarType;
- (id) initWithImage:(UIImage*)image andExistingDogEar:(DogEarObject*)object;

@property (nonatomic , retain) DogEarObject * existingDogEar;

@end
