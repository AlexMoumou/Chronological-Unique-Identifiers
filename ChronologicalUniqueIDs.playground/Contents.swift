    import Foundation
    
    private let ASC_CHARS = Array("-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz")
    private let DESC_CHARS = Array("zyxwvutsrqponmlkjihgfedcba_ZYXWVUTSRQPONMLKJIHGFEDCBA9876543210-")
    private var lastPushTime: UInt64 = 0
    private var lastRandChars = Array<Int>(repeating: 0, count: 12)
    
    /**
     Generates a unique identifier that is also chronological.
     - Note:
     A timestamp can be extracted with *getTimestampFromPushID(IDtoDecode: String) -> Int*
     */
    public func generatePushID(ascending: Bool = true) -> String {
        
        let PUSH_CHARS = ascending ? ASC_CHARS: DESC_CHARS
        var timeStampChars = Array<Character>(repeating: PUSH_CHARS.first!, count: 8)
        var now = UInt64(NSDate().timeIntervalSince1970 * 1000)
        let duplicateTime = (now == lastPushTime)
        lastPushTime = now
        
        for i in stride(from: 7, to: 0, by: -1) {
            timeStampChars[i] = PUSH_CHARS[Int(now % 64)]
            now >>= 6
        }
        
        assert(now == 0, "We should have converted the entire timestamp.")
        var id: String = String(timeStampChars)
        
        if !duplicateTime {
            for i in 0..<12 {
                lastRandChars[i] = Int(64 *  Double(arc4random()/2) / Double(RAND_MAX))
            }
        } else {
            
            var j :Int = 11
            
            for i in stride(from: 11, to: 0, by: -1){
                
                guard lastRandChars[i] == 63 else { break }
                
                lastRandChars[i] = 0
                j -= 1
            }
            
            lastRandChars[j] += 1
        }
        
        for i in 0..<12 {
            id.append(PUSH_CHARS[lastRandChars[i]])
        }
        
        assert( id.count == 20, "Length should be 20.")
        
        return id
    }
    
    
    ///Extracts the timestamp from unique and chronological id's created by *generatePushID(ascending: Bool = true) -> String*
    public func getTimestampFromPushID(IDtoDecode: String) -> Int{
        
        let timeStartIndex = IDtoDecode.index(IDtoDecode.startIndex, offsetBy: 8)
        let id = IDtoDecode[...timeStartIndex]
        var timestamp = 0
        var c: Character
        
        for i in stride(from: 0, to: 8, by: 1) {
            c = id[id.index(id.startIndex, offsetBy: i)]
            timestamp = timestamp * 64 + ASC_CHARS.firstIndex(of: c)!
        }
        
        return timestamp
    }
    
    let uniqueID = generatePushID()
    
    print(getTimestampFromPushID(IDtoDecode: uniqueID))
