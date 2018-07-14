//
//  CodableExtentions.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/11/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import CodableExtensions

public class MongodbObjectIdCodableTransformer: DecodingContainerTransformer, EncodingContainerTransformer {
	public typealias Input = [String:String]
	public typealias Output = String
	
	public init() {}
	
	public func transform(_ decoded: Input) throws -> Output {
		let _idString = decoded["$oid"];
		return _idString!;
	}
	
	public func transform(_ encoded: Output) throws -> Input {
		return ["$oid": encoded]
	}
}

public class HexColorTransformer: DecodingContainerTransformer, EncodingContainerTransformer {
	public typealias Input = String
	public typealias Output = UIColor
	
	public init() {}
	
	public func transform(_ decoded: Input) throws -> Output {
		return UIColor(hex: decoded);
	}
	
	public func transform(_ encoded: Output) throws -> Input {
		return encoded.toHexString(includeAlpha: false);
	}
}

