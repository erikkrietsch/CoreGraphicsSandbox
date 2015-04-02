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
    default:
        result = CGPoint(x: rect.width / 2, y: rect.height / 2)
    }
    return result
}

func squareRadius(rect: CGRect) -> CGFloat {
    return sqrt(pow(rectPoint(.Center, rect).x, 2) * 2)
}

@IBDesignable
class ShadowView: UIView {
    let OVERFLOW_FACTOR:  CGFloat = -0.25
    let CORNER_MULTPLIER: CGFloat =  1.4
    
    @IBInspectable var shadowSize: CGFloat = 75 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = UIColor.blackColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowAlpha: CGFloat = 0.33 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        let overdrawRect = rect //.rectByInsetting(dx: shadowSize * OVERFLOW_FACTOR, dy: shadowSize * OVERFLOW_FACTOR)
        println("overdrawRect \(overdrawRect)")
        println("rect \(rect)")
        
        // borders
        let leftShadowRect        = CGRect(x: overdrawRect.origin.x, y: overdrawRect.origin.y + shadowSize, width: shadowSize, height: overdrawRect.height - (shadowSize * 2))
        let topShadowRect         = CGRect(x: overdrawRect.origin.x + shadowSize, y: overdrawRect.origin.y, width: overdrawRect.width - (shadowSize * 2), height: shadowSize)
        let rightShadowRect       = CGRect(x: overdrawRect.width - shadowSize, y: overdrawRect.origin.y + shadowSize, width: shadowSize, height: leftShadowRect.height)
        let bottomShadowRect      = CGRect(x: overdrawRect.origin.x + shadowSize, y: overdrawRect.height - shadowSize, width: topShadowRect.width, height: shadowSize)

        println("leftShadowRect   \(leftShadowRect)")
        println("topShadowRect    \(topShadowRect)")
        println("rightShadowRect  \(rightShadowRect)")
        println("bottomShadowRect \(bottomShadowRect)")
        
//        CGContextSaveGState(ctx)
//        CGContextSetStrokeColorWithColor(ctx, UIColor.greenColor().CGColor)
//        CGContextStrokeRect(ctx, CGRect(x: 0, y: 0, width: shadowSize, height: shadowSize))
//        CGContextRestoreGState(ctx)
        
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

        // top-left
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, topLeftCornerRect)
        CGContextDrawRadialGradient(ctx, gradient, rectPoint(.BottomRight, topLeftCornerRect), squareRadius(topLeftCornerRect) * CORNER_MULTPLIER, rectPoint(.BottomRight, topLeftCornerRect), 0.0, drawingOptions)
        CGContextRestoreGState(ctx)

        // top-right
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, topRightCornerRect)
        CGContextDrawRadialGradient(ctx, gradient, rectPoint(.BottomLeft, topRightCornerRect), squareRadius(topRightCornerRect) * CORNER_MULTPLIER, rectPoint(.BottomLeft, topRightCornerRect), 0.0, drawingOptions)
        CGContextRestoreGState(ctx)

        // bottom-right
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, bottomRightCornerRect)
        CGContextDrawRadialGradient(ctx, gradient, rectPoint(.TopLeft, bottomRightCornerRect), squareRadius(bottomRightCornerRect) * CORNER_MULTPLIER, rectPoint(.TopLeft, bottomRightCornerRect), 0.0, drawingOptions)
        CGContextRestoreGState(ctx)

        // bottom-left
        CGContextSaveGState(ctx)
        CGContextClipToRect(ctx, bottomLeftCornerRect)
        CGContextDrawRadialGradient(ctx, gradient, rectPoint(.TopRight, bottomLeftCornerRect), squareRadius(bottomLeftCornerRect) * CORNER_MULTPLIER, rectPoint(.TopRight, bottomLeftCornerRect), 0.0, drawingOptions)
        CGContextRestoreGState(ctx)

        
        
        
    }
    
}
