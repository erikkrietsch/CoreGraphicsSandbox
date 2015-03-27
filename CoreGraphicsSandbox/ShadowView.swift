import UIKit
import QuartzCore

enum RectPoint {
    case Center
    case TopLeft
    case TopRight
    case BottomRight
    case BottomLeft
}

func rectPoint(point: RectPoint, rect: CGRect) -> CGPoint {
    var result: CGPoint
    switch point {
    case .TopLeft:
        result = CGPoint(x: rect.origin.x, y: rect.origin.y)
    case .TopRight:
        result = CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y)
    case .BottomRight:
        result = CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height)
    case .BottomLeft:
        result = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height)
    case .Center:
        result = CGPoint(x: rect.width / 2, y: rect.height / 2)
    }
    return result
}

func squareRadius(rect: CGRect) -> CGFloat {
    return sqrt(pow(rectPoint(.Center, rect).x, 2) * 2)
}

@IBDesignable
class ShadowView: UIView {
    @IBInspectable var shadowSize: CGFloat = 25.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = UIColor.blackColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowAlpha: CGFloat = 0.25 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        // borders
        let leftShadowRect        = CGRect(x: 0, y: shadowSize, width: shadowSize, height: rect.height - (shadowSize * 2))
        let topShadowRect         = CGRect(x: shadowSize, y: 0, width: rect.width - (shadowSize * 2), height: shadowSize)
        let rightShadowRect       = CGRect(x: rect.width - shadowSize, y: shadowSize, width: shadowSize, height: leftShadowRect.height)
        let bottomShadowRect      = CGRect(x: shadowSize, y: rect.height - shadowSize, width: topShadowRect.width, height: shadowSize)
        
        // corners
        let topLeftCornerRect     = CGRect(x: leftShadowRect.origin.x, y: topShadowRect.origin.y, width: leftShadowRect.width, height: topShadowRect.height)
        let topRightCornerRect    = CGRect(x: rightShadowRect.origin.x, y: topShadowRect.origin.y, width: rightShadowRect.width, height: topShadowRect.height)
        let bottomLeftCornerRect  = CGRect(x: leftShadowRect.origin.x, y: bottomShadowRect.origin.y, width: leftShadowRect.width, height: bottomShadowRect.height)
        let bottomRightCornerRect = CGRect(x: rightShadowRect.origin.x, y: bottomShadowRect.origin.y, width: rightShadowRect.width, height: bottomShadowRect.height)
        
        let space = CGColorSpaceCreateDeviceRGB()
        let blendColor: UIColor = backgroundColor == nil ? UIColor.clearColor() : backgroundColor!
        let colors: [CGColor] = [shadowColor.colorWithAlphaComponent(shadowAlpha).CGColor, blendColor.CGColor]
        let locations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradientCreateWithColors(space, colors, locations)
        
        // left
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, leftShadowRect)
        CGContextDrawLinearGradient(ctx, gradient, CGPoint(x: leftShadowRect.origin.x, y: leftShadowRect.height / 2), CGPoint(x: leftShadowRect.width, y: leftShadowRect.height / 2), 0)
        CGContextRestoreGState(ctx)
        
        // top
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, topShadowRect)
        CGContextDrawLinearGradient(ctx, gradient, CGPoint(x: topShadowRect.width / 2, y: topShadowRect.origin.y), CGPoint(x: topShadowRect.width / 2, y: topShadowRect.height), 0)
        CGContextRestoreGState(ctx)
        
        // right
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, rightShadowRect)
        CGContextDrawLinearGradient(ctx, gradient, CGPoint(x: rightShadowRect.origin.x + rightShadowRect.width, y: rightShadowRect.height / 2), CGPoint(x: rightShadowRect.origin.x, y: rightShadowRect.height / 2), 0)
        CGContextRestoreGState(ctx)

        // bottom
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, bottomShadowRect)
        CGContextDrawLinearGradient(ctx, gradient, CGPoint(x: topShadowRect.width / 2, y: bottomShadowRect.origin.y + bottomShadowRect.height), CGPoint(x: bottomShadowRect.width / 2, y: bottomShadowRect.origin.y), 0)
        CGContextRestoreGState(ctx)
        
        let drawingOptions = CGGradientDrawingOptions(kCGGradientDrawsBeforeStartLocation)
        let cornerMupltiplier = CGFloat(1.4)

        // top-left
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, topLeftCornerRect)
        CGContextDrawRadialGradient(ctx, gradient, rectPoint(.BottomRight, topLeftCornerRect), squareRadius(topLeftCornerRect) * cornerMupltiplier, rectPoint(.BottomRight, topLeftCornerRect), 0.0, drawingOptions)
        CGContextRestoreGState(ctx)

        // top-right
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, topRightCornerRect)
        CGContextDrawRadialGradient(ctx, gradient, rectPoint(.BottomLeft, topRightCornerRect), squareRadius(topRightCornerRect) * cornerMupltiplier, rectPoint(.BottomLeft, topRightCornerRect), 0.0, drawingOptions)
        CGContextRestoreGState(ctx)

        // bottom-right
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, bottomRightCornerRect)
        CGContextDrawRadialGradient(ctx, gradient, rectPoint(.TopLeft, bottomRightCornerRect), squareRadius(bottomRightCornerRect) * cornerMupltiplier, rectPoint(.TopLeft, bottomRightCornerRect), 0.0, drawingOptions)
        CGContextRestoreGState(ctx)

        // bottom-left
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, bottomLeftCornerRect)
        CGContextDrawRadialGradient(ctx, gradient, rectPoint(.TopRight, bottomLeftCornerRect), squareRadius(bottomLeftCornerRect) * cornerMupltiplier, rectPoint(.TopRight, bottomLeftCornerRect), 0.0, drawingOptions)
        CGContextRestoreGState(ctx)

        
        
        
    }
    
}
