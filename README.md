Time Crunch Trivia

Overview

Time Crunch Trivia is an engaging trivia app designed for trivia and competition lovers. Built entirely in Swift using Xcode, the app provides a dynamic trivia experience with three main modes of play:

Daily Challenge: A global competition where everyone receives the same 10 questions, and players can share their scores with friends.

Random Mode: Play trivia on your own with a variety of questions.

Category Mode: Focus on specific trivia categories tailored to your interests.

The app is backed by a custom RESTful API designed using MongoDB Atlas, providing a seamless experience for storing and retrieving user scores and global challenges. To support monetization, the app incorporates Google AdMob with banner ads on the homepage and interstitial ads after gameplay.

Features

Daily Challenge: Compete globally with 10 new questions every day.

Random and Category Modes: Play independently with customizable options.

Custom API Integration:

Scores from the daily challenge are stored and retrieved via a custom RESTful API.

Built with MongoDB Atlas and JavaScript-based endpoints.

Google AdMob Support:

Banner Ads: Displayed on the homepage.

Interstitial Ads: Shown after completing a game.

Modern Design: Intuitive UI built for iOS 18.0+.

Technical Details

Frontend

Language: Swift

Framework: Xcode

Platform: iOS 18.0+

Backend

Database: MongoDB Atlas

API: RESTful, built using JavaScript

Monetization

Integrated Google AdMob:

Banner ads

Interstitial ads

Challenges and Learnings

Asynchronous API Calls

One of the significant challenges faced during development was managing the asynchronous nature of API calls, particularly when handling data from multiple APIs under varying internet conditions. Debugging these issues was complicated but ultimately resolved by conducting extensive beta testing. Early access provided to friends and family helped identify and fix edge cases.

How to Run Locally

While this app is not intended to be run locally, developers can explore the project by following these steps:

Prerequisites

Xcode (latest version)

iOS device or simulator running iOS 18.0+

An active MongoDB Atlas cluster (if replicating the backend)

Steps

Clone the repository.

Open the project in Xcode.

Set up the necessary API endpoints and credentials in the configuration file.

Build and run the app on an iOS simulator or physical device.

Screenshots

[Add screenshots of the app interface here, such as the homepage, gameplay screen, and leaderboard.]

Future Improvements

Expanded Gameplay Modes: Adding team-based challenges and multiplayer options.

Cross-Platform Support: Adapting the app for Android devices.

Enhanced Analytics: Incorporating user performance metrics for more personalized trivia experiences.

Contact

Feel free to reach out for any questions or feedback:

Email: [Your Email Address]

Portfolio: [Link to your portfolio]

LinkedIn: [Your LinkedIn Profile]

License

This project is licensed under the MIT License. See the LICENSE file for details.
