Flutter Budget Tracker

A cross-platform personal finance management application built with Flutter. This app helps users track their monthly income and expenses, visualize spending patterns through interactive charts, and receive smart financial advice via an AI-driven assistant.

Features

Monthly Budget Management: Set your monthly income and track your remaining balance in real-time.

Transaction Logging: Easily add expenses with titles, amounts, and specific categories (Food, Transport, Shopping, etc.).

Dynamic Data Visualization: View a breakdown of your spending habits with an interactive, category-based pie chart.

Monthly Navigation: Seamlessly switch between months to review past financial data and trends.

AI Budget Assistant: Get personalized, actionable advice based on your spending percentages to help you save more effectively.

Data Export: Export your monthly transaction history to a CSV format, compatible with Microsoft Excel and Google Sheets.

Premium Dark UI: A clean, modern dark-themed interface designed for readability and focus.

Tech Stack

Framework: Flutter

Language: Dart

Packages:

intl: For currency and date formatting.

pie_chart: For interactive data visualization.

csv: For generating exportable data reports.

Installation

To get this project running locally, follow these steps:

Clone the repository:

git clone [https://github.com/yourusername/budget-tracker.git](https://github.com/yourusername/budget-tracker.git)
cd budget-tracker


Update Dependencies:
Ensure your pubspec.yaml includes the following:

dependencies:
  flutter:
    sdk: flutter
  intl: ^0.19.0
  pie_chart: ^5.4.0
  csv: ^6.0.0


Install Packages:
Run the following command in your terminal:

flutter pub get


Run the App:

flutter run


Usage

Set Income: Click the edit icon in the "SUMMARY" card to enter your monthly earnings.

Add Expense: Tap the "+" Floating Action Button at the bottom center. Enter the details and select a category.

Analyze: Use the pie chart to identify which categories consume most of your budget.

Get Advice: Tap the lightbulb icon in the month selector to open the AI Budget Assistant.

Export: Tap the download icon to generate a CSV string of your current month's data (visible in the debug console).


