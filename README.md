# Time Crunch Trivia

# App Store Link: 
https://apps.apple.com/us/app/time-crunch-trivia/id6478566589 

## Overview
**Time Crunch Trivia** is an engaging trivia app designed for trivia and competition lovers. Built entirely in Swift using Xcode, the app provides a dynamic trivia experience with three main modes of play:

- **Daily Challenge:** A global competition where everyone receives the same 10 questions, and players can share their scores with friends.
- **1 Minute Challenge:** Race the clock on your own with a variety of questions.
- **Custom Mode:** Focus on specific trivia categories tailored to your interests.

The app is backed by a custom RESTful API designed using MongoDB Atlas, providing a seamless experience for global challenges. To support monetization, the app incorporates Google AdMob with banner ads on the homepage and interstitial ads after gameplay.

---

## Features
- **Daily Challenge:** Compete globally with 10 new questions every day.
- **Random and Category Modes:** Play independently with customizable options.
- **Custom API Integration:**
  - A custom API updates at midnight EST with a new category from [The Trivia API](https://the-trivia-api.com/)
  - Built with MongoDB Atlas and JavaScript-based endpoints.
- **Google AdMob Support:**
  - **Banner Ads:** Displayed on the homepage.
  - **Interstitial Ads:** Shown after completing a game.
- **Modern Design:** Intuitive UI built for iOS 18.0+.

---

## Technical Details
### Frontend
- **Language:** Swift
- **Framework:** Xcode
- **Platform:** iOS 18.0+

### Backend
- **Database:** MongoDB Atlas
- **API:** RESTful, built using JavaScript, and [The Trivia API](https://the-trivia-api.com/)

### Monetization
- Integrated Google AdMob:
  - Banner ads
  - Interstitial ads

---

## Challenges and Learnings
### Asynchronous API Calls
One of the significant challenges faced during development was managing the asynchronous nature of API calls, particularly when handling data from multiple APIs under varying internet conditions. Debugging these issues was complicated but ultimately resolved by conducting extensive beta testing. Early access provided to friends and family helped identify and fix edge cases.

---

## Screenshots
<img width="202" alt="Screenshot 2024-12-15 at 11 48 48 AM" src="https://github.com/user-attachments/assets/9543d6b0-5119-48aa-850a-375c40d6ffaa" />
<img width="200" alt="Screenshot 2024-12-15 at 11 48 53 AM" src="https://github.com/user-attachments/assets/ccaaa922-c81b-48f7-87e7-8282fcf85315" />
<img width="203" alt="Screenshot 2024-12-15 at 11 48 57 AM" src="https://github.com/user-attachments/assets/18c9cb5b-7b73-427f-9d49-2ec4cdafed4e" />


---

## Future Improvements
- **In-App Score Sharing:** Adding login features so users can connect, share scores, and participate in leaderboards
- **Cross-Platform Support:** Adapting the app for Android devices.
- **Enhanced Analytics:** Incorporating user performance metrics for more personalized trivia experiences.

---

## Contact
Feel free to reach out for any questions or feedback:
- **Email:** samreed12@att.net
- **Portfolio:** [sam-reed.com](https://sam-reed.com)
- **LinkedIn:** [https://www.linkedin.com/in/sam-reed12/]

---

## License
This project is licensed under the MIT License. See the LICENSE file for details.

