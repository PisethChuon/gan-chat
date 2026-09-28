# Software Architecture Document
**Project Name:** GanChat  
**Target Audience:** Gen Z users  
**Document Type:** Software Architecture Document (SAD)  
---
## 1. Introduction & Overview
### 1.1 Purpose
This document provides a comprehensive architectural overview of the **GanChat** application. It details the structural design, system components, data flow, domain models, and technical decisions governing the v1 Minimum Viable Product (MVP).

### 1.2 Product Vision & Problem Statement
- **App Name:** GanChat  
- **Description:** A simple, chat application designed for Gen Z users to register, find people, and initiate one-to-one messaging with minimal friction and zero setup overhead.
- **Problem Solved:** Existing messaging platforms are heavily bloated with complex features. GanChat addresses this by delivering a lightweight, clean, and responsive text communication platform.
- **Target Audience:** Young users desiring a minimal, fast, and feature-focused messaging application.

### 1.3 Scope (MVP vs. Out of Scope)
* **MVP Features (v1):**
  * User Registration, Login, and Logout
  * Basic User Profile (Email, Username, User ID)
  * Conversation List
  * One-to-one Direct Text Messaging
  * Persistent Message History & Near Real-time Synchronisation
  * Offline-first local messaging with automatic syncing
* **Explicitly Out of Scope for v1:**
  * Group Chat
  * Message Reactions
  * Voice Messages
  * Video Calls
  * Stories
