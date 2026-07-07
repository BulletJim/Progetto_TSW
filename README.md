# 🏋️‍♂️ IronAxis E-Commerce

> A robust, full-featured Java Web E-Commerce application built with Servlets, JSP, and MySQL, following a strict MVC architecture and DAO pattern.

![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=java&logoColor=white)
![JSP/Servlets](https://img.shields.io/badge/JSP_/_Servlets-007396?style=for-the-badge&logo=java&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)
![Tomcat](https://img.shields.io/badge/Apache_Tomcat-F8DC75?style=for-the-badge&logo=apache-tomcat&logoColor=black)

## 📖 Table of Contents
- [About the Project](#about-the-project)
- [Key Features](#key-features)
- [Database Architecture](#database-architecture)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)

## <a id="about-the-project"></a>🚀 About the Project
**IronAxis** is a comprehensive e-commerce platform developed as a university project. It provides a complete shopping experience, from browsing products and managing the shopping cart to a secure checkout process. 

The backend is engineered for reliability, featuring ACID-compliant database transactions, atomic inventory management, dynamic BLOB file serving (images and nutritional tables), and automated PDF document generation for accounting compliance.

## <a id="key-features"></a>✨ Key Features
- **User Authentication:** Secure registration and login system with password hashing.
- **Dynamic Catalog:** Browse products with multiple variants (SKU, size, flavour). Images are fetched dynamically from the database via a custom `DisplayFileServlet`.
- **Advanced Cart & Checkout:** Persistent shopping cart with real-time, atomic inventory deduction to prevent overselling.
- **Order History Preservation:** Implementation of the **Data Snapshot Pattern**. Orders and Invoices store immutable copies of prices and addresses at the time of purchase, ensuring historical data integrity even if user profiles or products are updated/deleted.
- **Automated PDF Invoices:** Invoices are automatically generated and compiled into official PDF documents upon order confirmation using the **OpenPDF** library.
- **Print-Ready Web Layouts:** Invoice pages are also optimized using CSS `@media print` queries for seamless browser-native printing and saving.
- **Product Reviews:** Users can leave ratings and comments on purchased products.

## <a id="database-architecture"></a>🗄️ Database Architecture
The database (`ecommerce_IronAxis`) is designed with data integrity in mind:
- **Soft Deletes:** Entities like `users` and `products` use an `is_deleted` flag rather than physical deletion, preserving referential integrity.
- **Data Denormalization (Orders):** The `orders`, `order_details`, and `invoices` tables are completely decoupled from live product/user data, storing frozen snapshots of strings and values to guarantee accounting compliance.
- **Connection Pooling:** Managed via Tomcat's `DataSource` for optimized performance and resource management.

## <a id="tech-stack"></a>💻 Tech Stack
- **Backend:** Java EE (Servlets 3.1, JSP, JDBC)
- **PDF Generation:** OpenPDF (LGPL-licensed fork of iText)
- **Frontend:** HTML5, CSS3 (Custom Media Queries), JavaScript
- **Database:** MySQL 8.x
- **Server:** Apache Tomcat 9+
- **Architecture:** Model-View-Controller (MVC) & Data Access Object (DAO)

## <a id="getting-started"></a>🛠️ Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites
- [Java JDK 21+](https://www.oracle.com/java/technologies/javase-downloads.html)
- [Apache Tomcat 9.0+](https://tomcat.apache.org/download-90.cgi)
- [MySQL Server](https://dev.mysql.com/downloads/)
- An IDE like Eclipse IDE for Enterprise Java or IntelliJ IDEA Ultimate.

### Installation & Setup

1. **Clone the repository:**
   ```sh
   git clone https://github.com/bulletjim/iron-axis-ecommerce.git   ```

2. **Database Setup:**
   - Open your MySQL client and run the provided SQL DDL script to generate the `ecommerce_IronAxis` database and tables.
   - Run the DML script (if provided) to populate the database with mock data.

3. **Configure the DataSource:**
   - Navigate to your Tomcat configuration (`context.xml` inside `META-INF` or Tomcat's `conf` folder).
   - Add the JDBC Resource link mapping to your local MySQL credentials:
     ```xml
     <Resource name="jdbc/ecommerce_db" auth="Container" type="javax.sql.DataSource"
               maxTotal="100" maxIdle="30" maxWaitMillis="10000"
               username="root" password="your_password" driverClassName="com.mysql.cj.jdbc.Driver"
               url="jdbc:mysql://localhost:3306/ecommerce_IronAxis?serverTimezone=UTC"/>
     ```

4. **Deploy:**
   - Add the project to your Tomcat server within your IDE.
   - Start the server and navigate to `http://localhost:8080/IronAxis`.

## <a id="project-structure"></a>📂 Project Structure

```text
src/
└── it.unisa.backend/
    ├── controller/                 # Servlets handling HTTP requests
    ├── filter/                     # Security and download filters (AdminFilter, DownloadInvoiceFilter)
    ├── listener/                   # Application lifecycle listeners (ContextInitializerListener)
    ├── model/
    │   ├── bean/                   # POJOs representing database entities (The Models)
    │   │   ├── dto/                # Data Transfer Objects
    │   │   └── util/               # Application Enumerations (e.g., OrderStatus, PaymentStatus)
    │   ├── dao/                    # DAO interfaces and implementations (Data Access Object)
    │   └── db/                     # DBManager and DataSource connection pooling configuration
    └── util/                       # Cryptographic helpers (Password hashing and salt generation functions)
WebContent/
├── css/                            # Static stylesheets for presentation
├── error/                          # Custom error fallback pages (e.g., 404 and 500 HTML/JSP files)
├── js/                             # Frontend JavaScript assets
├── META-INF/                       # Meta configuration folder (contains Context.xml)
├── WEB-INF/
│   ├── fragment/                   # Reusable JSP fragments (Header, Footer, Navbar)
│   ├── lib/                        # Embedded JAR dependencies (OpenPDF, MySQL Connector)
│   ├── view/                       # Protected JSP presentation views (MVC Views)
│   └── web.xml                     # Web deployment descriptor configuration
├── assistance.jsp                  # Customer support and assistance page
├── index.jsp                       # Application main landing page (Entry Point)
└── ordersinfo.jsp                  # User order tracking and details page
```