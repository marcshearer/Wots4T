//
//  Attachment View Model.swift
//  Wots4T
//
//  Created by Marc Shearer on 19/02/2021.
//

import Foundation

public class AttachmentViewModel : Equatable, Hashable {
    public var attachmentId: UUID
    public var sequence: Int
    public var attachment: Data?
    
    init(attachmentId: UUID? = nil, sequence: Int? = nil, attachment: Data? = nil) {
        self.attachmentId = attachmentId ?? UUID()
        self.sequence = sequence ?? Int(Int16.max)
        self.attachment = attachment
    }
    
    public static func == (lhs: AttachmentViewModel, rhs: AttachmentViewModel) -> Bool {
        return lhs.attachmentId == rhs.attachmentId && lhs.sequence == rhs.sequence && lhs.attachment == rhs.attachment
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(attachmentId)
        hasher.combine(self.sequence)
        hasher.combine(self.attachment)
    }
}
