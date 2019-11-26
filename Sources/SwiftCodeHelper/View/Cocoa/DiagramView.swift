import Cacao
import Foundation
import DisplayLogic
import Logging

class DiagramView: UIView {

    private var logger: Logger

    private let model: SystemModel

    override var intrinsicContentSize: CGSize {
        CGSize.init(width: 1000, height: 1000)
    }

    init(frame: CGRect, model: SystemModel) {

        self.model = model
        self.logger = Logger.init(label: "cocoa.DiagramView")
        self.logger.logLevel = .debug

        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear
        self.frame.size = CGSize.init(width: 1000, height: 1000)

        
    }

    override func draw(_ rect: CGRect) {

        logger.debug("Drawing the model...")

        var modelArrangementHead = model_arrangement_rect_node()
        var modelArrangementCurrent = modelArrangementHead

        model.classes.forEach{ clz in 

            let typeName = UnsafeMutablePointer<CChar>(mutating: clz.name)
            var dimensionsRect = model_arrangement_computeRectDimensionsFor(typeName, 0)
            print("Dim Rect [\(clz.name)]=\(dimensionsRect)")
            modelArrangementCurrent.rect = withUnsafeMutablePointer(to: &dimensionsRect) { $0 }

            var next = model_arrangement_rect_node()
            modelArrangementHead.next = withUnsafeMutablePointer(to: &next) { $0 }
            modelArrangementHead = next

        }

        withUnsafeMutablePointer(to: &modelArrangementHead) { model_arrangement_ArrangeRectangles($0) }

        //  Convert the queue to an array
        var currentModelArrangementNode : model_arrangement_rect_node? = modelArrangementHead
        var modelArrangementRects: [model_arrangement_rect] = []
        repeat {
            if let currentNode = currentModelArrangementNode {
                modelArrangementRects.append(currentNode.rect.pointee)
                currentModelArrangementNode = currentNode.next.pointee
            }
        } while currentModelArrangementNode != nil

        logger.debug("Got \(modelArrangementRects)")
        modelArrangementRects.forEach{ rect in 
            logger.debug("\(rect)")
        }

        // let littleRectangle = CGRect.init(x: rect.origin.x + 10, y: rect.origin.y + 10, width: 100, height: 100)

        

        // let path = UIBezierPath(rect: rect)
        // UIColor.green.setFill()
        // path.fill()

        // let littlePath = UIBezierPath.init(rect: littleRectangle)
        // littlePath.lineWidth = CGFloat(6.0)
        // littlePath.stroke()

        // let textRect = CGRect.init(x: rect.origin.x + 200, y: rect.origin.y+10, width: 200, height: 40)
        // let label = UILabel.init(frame: textRect)
        // label.text = "Test Label"
        // addSubview(label)

        // UIColor.red.setStroke()
        // let littleLineMaker = UIBezierPath()
        // littleLineMaker.move(to: textRect.origin)
        // littleLineMaker.addLine(to: littleRectangle.origin)
        // littleLineMaker.lineWidth = 2
        // littleLineMaker.stroke()

    }
    

}