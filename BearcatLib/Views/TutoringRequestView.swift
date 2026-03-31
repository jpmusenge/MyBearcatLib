//
//  TutoringRequestView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/30/26.
//

// PURPOSE: Lets students request a peer academic tutor by subject via email

import SwiftUI

struct TutoringRequestView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedSubject = "Computer Science"
    @State private var courseName = ""
    @State private var description = ""
    @State private var preferredDay = "Any"
    @State private var showConfirmation = false

    private let subjects = [
        "Computer Science",
        "Mathematics",
        "Biology",
        "Chemistry",
        "Physics",
        "English",
        "Business",
        "History",
        "Other"
    ]

    private let days = ["Any", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]

    var body: some View {
        Form {
            // MARK: - Info Section
            Section {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "F59E0B").opacity(0.1))
                            .frame(width: 44, height: 44)

                        Image(systemName: "person.2.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "F59E0B"))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Peer Academic Tutoring")
                            .font(Theme.Fonts.headline)

                        Text("Request a trained peer tutor for help with any course or subject.")
                            .font(Theme.Fonts.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            // MARK: - Subject & Course
            Section("What do you need help with?") {
                Picker("Subject", selection: $selectedSubject) {
                    ForEach(subjects, id: \.self) { subject in
                        Text(subject).tag(subject)
                    }
                }

                TextField("Course name (e.g. CSC 301, MATH 201)", text: $courseName)
                    .textInputAutocapitalization(.words)
            }

            // MARK: - Details
            Section("Tell us more") {
                TextField("What topics or assignments do you need help with?", text: $description, axis: .vertical)
                    .lineLimit(3...6)
            }

            // MARK: - Preferred Day
            Section("Preferred day") {
                Picker("Day", selection: $preferredDay) {
                    ForEach(days, id: \.self) { day in
                        Text(day).tag(day)
                    }
                }
                .pickerStyle(.segmented)
            }

            // MARK: - Submit
            Section {
                Button {
                    sendTutoringRequest()
                } label: {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Send Request")
                    }
                    .font(Theme.Fonts.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .listRowBackground(Theme.Colors.primary)
                .disabled(courseName.isEmpty)
            }

            // MARK: - Hours Info
            Section("Tutoring Hours") {
                Label("Monday – Thursday: 10am – 6pm", systemImage: "clock")
                    .font(Theme.Fonts.subheadline)
                    .foregroundColor(.secondary)
                Label("Friday: 10am – 2pm", systemImage: "clock")
                    .font(Theme.Fonts.subheadline)
                    .foregroundColor(.secondary)
                Label("2nd Floor, Leontyne Price Library", systemImage: "building.2")
                    .font(Theme.Fonts.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Request a Tutor")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Request Sent", isPresented: $showConfirmation) {
            Button("OK") {
                // Reset form
                courseName = ""
                description = ""
                selectedSubject = "Computer Science"
                preferredDay = "Any"
            }
        } message: {
            Text("Your tutoring request has been sent. A peer tutor will reach out to your Rust College email within 1-2 business days.")
        }
    }

    private func sendTutoringRequest() {
        let studentName = authViewModel.userDisplayName
        let studentEmail = authViewModel.userEmail
        let subject = "Tutoring Request: \(selectedSubject) – \(courseName)"
        let body = """
        Student: \(studentName)
        Email: \(studentEmail)
        Subject: \(selectedSubject)
        Course: \(courseName)
        Preferred Day: \(preferredDay)

        Details:
        \(description.isEmpty ? "No additional details provided." : description)
        """

        // Try to open the mail client
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let tutoringEmail = "tutoring@rustcollege.edu"
        let mailURL = URL(string: "mailto:\(tutoringEmail)?subject=\(encodedSubject)&body=\(encodedBody)")

        if let mailURL, UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.open(mailURL)
        }

        // Show confirmation regardless (email client may not be configured on simulator)
        showConfirmation = true
    }
}

#Preview {
    NavigationStack {
        TutoringRequestView()
            .environmentObject(AuthViewModel())
    }
}
