import AppKit
import ApplicationServices
import Foundation

enum AccessibilityTextService {
    static func replaceSelectedText(with replacement: String) -> Bool {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return false
        }

        let appElement = AXUIElementCreateApplication(frontmostApp.processIdentifier)
        guard let focusedElement = focusedElement(in: appElement) else {
            return false
        }

        guard
            let currentValue = stringValue(of: focusedElement),
            var selectedRange = selectedTextRange(of: focusedElement)
        else {
            return false
        }

        let nsValue = currentValue as NSString
        let selectedNSRange = NSRange(location: selectedRange.location, length: selectedRange.length)
        guard selectedNSRange.location != NSNotFound, NSMaxRange(selectedNSRange) <= nsValue.length else {
            return false
        }

        let updatedValue = nsValue.replacingCharacters(in: selectedNSRange, with: replacement)
        let setValueStatus = AXUIElementSetAttributeValue(
            focusedElement,
            kAXValueAttribute as CFString,
            updatedValue as CFTypeRef
        )
        guard setValueStatus == .success else {
            return false
        }

        selectedRange = CFRange(location: selectedRange.location + (replacement as NSString).length, length: 0)
        if let rangeValue = AXValueCreate(.cfRange, &selectedRange) {
            _ = AXUIElementSetAttributeValue(
                focusedElement,
                kAXSelectedTextRangeAttribute as CFString,
                rangeValue
            )
        }

        return true
    }

    private static func focusedElement(in appElement: AXUIElement) -> AXUIElement? {
        guard let value = attributeValue(kAXFocusedUIElementAttribute as CFString, of: appElement) else {
            return nil
        }
        return unsafeDowncast(value, to: AXUIElement.self)
    }

    private static func stringValue(of element: AXUIElement) -> String? {
        attributeValue(kAXValueAttribute as CFString, of: element) as? String
    }

    private static func selectedTextRange(of element: AXUIElement) -> CFRange? {
        guard let value = attributeValue(kAXSelectedTextRangeAttribute as CFString, of: element) else {
            return nil
        }

        let axValue = unsafeDowncast(value, to: AXValue.self)
        guard AXValueGetType(axValue) == .cfRange
        else {
            return nil
        }

        var range = CFRange()
        guard AXValueGetValue(axValue, .cfRange, &range) else {
            return nil
        }

        return range
    }

    private static func attributeValue(_ attribute: CFString, of element: AXUIElement) -> CFTypeRef? {
        var value: CFTypeRef?
        let status = AXUIElementCopyAttributeValue(element, attribute, &value)
        guard status == .success else {
            return nil
        }
        return value
    }
}
