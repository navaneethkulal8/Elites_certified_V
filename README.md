# Elites Certified
### Mentor 
#### Dr.Suryanaraya K (HoD department of Electrical and Electronics Engineering)

## Video Demo
For a visual walkthrough of the Certificate Tracking System, please refer to the 

[![Video Demo](https://img.youtube.com/vi/_gNR7kkILaQ/0.jpg)](https://www.youtube.com/watch?v=_gNR7kkILaQ)


## Overview
The Certificate Tracking System is a comprehensive platform developed using Flutter and Firebase, designed to streamline and automate the process of tracking certificates and associated points in an educational or organizational setting. The system consists of three main user roles: Admin, Mentor, and Student, each with specific functionalities tailored to their responsibilities.

## System Architecture
The project is built on a client-server architecture. The Flutter framework is used for the client-side application, providing a cross-platform user interface, while Firebase serves as the backend, handling data storage, authentication, and real-time updates.

## User Roles and Functionalities
### Admin
- Create and manage batches: Admins can create batches, defining groups of students and assigning mentors to each batch.
- Assign mentors and students: Admins have the authority to assign mentors to specific batches and students to mentors.
- View all certificates: Admins can access a comprehensive overview of all certificates uploaded by students, facilitating efficient monitoring and management.

### Mentor
- Review and approve certificates: Mentors are responsible for reviewing certificates uploaded by students. They can approve or reject certificates based on the relevance of tags and requested points.
- Award points: If a mentor approves a certificate, they can award the requested points to the student.
- View batch certificates: Mentors can view and manage certificates within their assigned batches.

### Student
- Upload certificates: Students can upload certificates, attaching relevant tags to describe the associated activity.
- Request points: Students can request a specific number of points for each certificate uploaded.
- Track certificate status: Students can monitor the status of their certificates, including whether they have been approved and the awarded points.

## Workflow
### Certificate Upload
1. Students upload certificates with relevant tags and request points.
2. Mentors review uploaded certificates.

### Mentor Approval
1. Mentors approve or reject certificates based on relevance and accuracy.
2. If approved, mentors award requested points.

### Admin Management
1. Admins create and manage batches.
2. Admins assign mentors to batches and students to mentors.
3. Admins have access to a centralized view of all certificates.

## Database and Security
Firebase is utilized for data storage, ensuring a secure and scalable solution. Firebase Authentication is implemented for user authentication, ensuring secure access to the system.

## Benefits
- Streamlined certificate tracking process.
- Enhanced communication and collaboration among administrators, mentors, and students.
- Efficient batch management and assignment of responsibilities.

## Future Enhancements
- Integration of notifications for status updates.
- Analytics and reporting features for administrators.
- Gamification elements to encourage student participation.


