// MarsTimeComplicationProvider.swift
// Mars Clock System - watchOS Complication Timeline Provider
// NASA/JPL Flight Software Standard

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct MarsTimeEntry: TimelineEntry {
    let date: Date
    let marsTime: MarsTimeData?
}

// MARK: - Timeline Provider

struct MarsTimeComplicationProvider: TimelineProvider {
    typealias Entry = MarsTimeEntry
    
    let engine = MarsTimeEngine()
    
    // MARK: - Timeline Provider Methods
    
    func placeholder(in context: Context) -> MarsTimeEntry {
        let now = Date()
        let data = try? engine.calculate(earthUTC: now, longitudeEast: 0.0)
        return MarsTimeEntry(date: now, marsTime: data)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MarsTimeEntry) -> Void) {
        let now = Date()
        let data = try? engine.calculate(earthUTC: now, longitudeEast: 0.0)
        let entry = MarsTimeEntry(date: now, marsTime: data)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MarsTimeEntry>) -> Void) {
        // Generate timeline for next 24 hours at 5-minute intervals
        // More frequent updates for better accuracy
        let now = Date()
        var entries: [MarsTimeEntry] = []
        
        // Create entries every 5 minutes for 24 hours
        for minuteOffset in stride(from: 0, to: 24 * 60, by: 5) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: now)!
            let marsTime = try? engine.calculate(earthUTC: entryDate, longitudeEast: 0.0)
            entries.append(MarsTimeEntry(date: entryDate, marsTime: marsTime))
        }
        
        // Refresh after 24 hours
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 24, to: now)!
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }
}
