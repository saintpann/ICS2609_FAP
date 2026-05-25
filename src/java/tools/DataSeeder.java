package tools;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletContext;
import tools.Cryptograph;

public class DataSeeder {

    private static Connection getDerbyConnection(ServletContext context) throws SQLException, ClassNotFoundException {
        Class.forName("org.apache.derby.jdbc.ClientDriver");
        String url = context.getInitParameter("DerbyURL");
        String user = context.getInitParameter("DerbyUser");
        String pass = context.getInitParameter("DerbyPass");
        return DriverManager.getConnection(url, user, pass);
    }

    private static Connection getPostgresConnection(ServletContext context) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        String url = context.getInitParameter("ExamDBURL");
        String user = context.getInitParameter("ExamDBUser");
        String pass = context.getInitParameter("ExamDBPass");
        return DriverManager.getConnection(url, user, pass);
    }

    private static Connection getMysqlConnection(ServletContext context) throws SQLException, ClassNotFoundException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = context.getInitParameter("CertDBURL");
        String user = context.getInitParameter("CertDBUser");
        String pass = context.getInitParameter("CertDBPass");
        return DriverManager.getConnection(url, user, pass);
    }

    public static String seedDatabase(ServletContext context, String secretKey, String algo, String mode, String padding) {
        StringBuilder statusMessage = new StringBuilder();

        // ========================================================
        // 1. SEED APACHE DERBY (USERS)
        // ========================================================
        String derbyInsertQuery = "INSERT INTO Users (uname, pass, role) VALUES (?, ?, ?)";
        try (Connection conn = getDerbyConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(derbyInsertQuery)) {

            Cryptograph crypt = new Cryptograph(secretKey, algo, mode, padding);
            String encryptedDefaultPassword = crypt.encrypt("password123");

            for (int i = 1; i <= 3; i++) {
                pstmt.setString(1, "admin" + i);
                pstmt.setString(2, encryptedDefaultPassword); 
                pstmt.setString(3, "Admin");
                pstmt.addBatch();
            }
            for (int i = 1; i <= 50; i++) {
                pstmt.setString(1, "student" + i);
                pstmt.setString(2, encryptedDefaultPassword); 
                pstmt.setString(3, "Student");
                pstmt.addBatch();
            }
            pstmt.executeBatch();
            statusMessage.append("Derby (Users) OK. ");
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR during Derby Seeding: " + e.getMessage();
        }

        // ========================================================
        // 2. SEED MYSQL (DASHBOARD CERTIFICATION HISTORY)
        // ========================================================
        String mysqlInsert = "INSERT INTO Certifications (uname, course_code, score, issue_date) VALUES (?, ?, ?, ?)";
        try (Connection conn = getMysqlConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(mysqlInsert)) {
            
            // Student 1 History
            String[][] s1Data = {
                {"student1", "JAVA101", "98.50", "2025-01-10 14:30:00"},
                {"student1", "DEV201", "88.00", "2025-02-15 09:15:00"},
                {"student1", "PYT301", "100.00", "2025-03-20 16:45:00"},
                {"student1", "SQL121", "92.50", "2025-04-05 11:00:00"}
            };
            // Student 2 History
            String[][] s2Data = {
                {"student2", "AGI401", "95.00", "2025-01-12 10:00:00"},
                {"student2", "ITIL501", "82.50", "2025-02-28 13:20:00"},
                {"student2", "SEC601", "89.00", "2025-03-10 15:10:00"}
            };

            for (String[] row : s1Data) {
                pstmt.setString(1, row[0]); pstmt.setString(2, row[1]);
                pstmt.setDouble(3, Double.parseDouble(row[2])); pstmt.setString(4, row[3]);
                pstmt.addBatch();
            }
            for (String[] row : s2Data) {
                pstmt.setString(1, row[0]); pstmt.setString(2, row[1]);
                pstmt.setDouble(3, Double.parseDouble(row[2])); pstmt.setString(4, row[3]);
                pstmt.addBatch();
            }
            pstmt.executeBatch();
            statusMessage.append("MySQL (Certifications) OK. ");
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR during MySQL Seeding: " + e.getMessage();
        }

        // ========================================================
        // 3. SEED POSTGRESQL (12 COURSES & 240 QUESTIONS)
        // ========================================================
        String courseInsertSQL = "INSERT INTO Courses (course_code, course_title, description) VALUES (?, ?, ?) RETURNING course_id";
        String questionInsertSQL = "INSERT INTO Questions (course_id, question_text, correct_answer) VALUES (?, ?, ?)";

        try (Connection conn = getPostgresConnection(context)) {
            conn.setAutoCommit(false); 

            try (PreparedStatement pstmtCourse = conn.prepareStatement(courseInsertSQL);
                 PreparedStatement pstmtQuestion = conn.prepareStatement(questionInsertSQL);
                 Statement stmtSeq = conn.createStatement()) {

                // Define all 12 Courses
                String[][] courses = {
                    {"JAVA101", "Java Web Development", "Master enterprise Java architectures, Servlet life cycles, and advanced JSP integrations."},
                    {"DEV201", "DevOps Engineering", "Validate your knowledge in CI/CD pipelines, containerization, and infrastructure as code."},
                    {"PYT301", "Python Programming", "Test your proficiency in Python algorithms, data structures, and object-oriented paradigms."},
                    {"AGI401", "Agile ScrumMaster", "Official evaluation covering Agile methodologies, sprint planning, and Scrum ceremonies."},
                    {"ITIL501", "ITIL 4 Foundation", "Demonstrate understanding of modern IT service management and organizational value delivery."},
                    {"SEC601", "Cybersecurity Fundamentals", "Assess your knowledge of threat vectors, network defense mechanisms, and access control."},
                    {"CMP701", "CompTIA A+ Certification", "Prove your ability to support IT enterprise systems by validating hardware, networks, and OS metrics."},
                    {"CMP801", "CompTIA Security+", "Validate the baseline skills necessary to improve global network resilience operations."},
                    {"CMP901", "CompTIA Tech+", "An entry-level certification validating foundational knowledge covering cloud storage concepts."},
                    {"PBI101", "Microsoft Power BI Data Analyst", "Learn to clean, transform, and map corporate metrics into readable value streams."},
                    {"AZU111", "Microsoft Azure Fundamentals", "Prove your foundational knowledge regarding core enterprise cloud platform components."},
                    {"SQL121", "SQL for Data Analysis", "Write efficient queries, perform aggregations, and query relational data nodes."}
                };

                // Map to track auto-generated sequence IDs against their code keys
                Map<String, Integer> courseIdMap = new HashMap<>();

                for (String[] c : courses) {
                    pstmtCourse.setString(1, c[0]);
                    pstmtCourse.setString(2, c[1]);
                    pstmtCourse.setString(3, c[2]);
                    try (ResultSet rs = pstmtCourse.executeQuery()) {
                        if (rs.next()) {
                            courseIdMap.put(c[0], rs.getInt(1));
                        }
                    }
                }

                // Raw 240 Question Data Map array mapping back to code groups
                String[][] rawQuestions = {
                    // JAVA101
                    {"JAVA101", "Which Java interface is used to create a servlet?", "HttpServlet"},
                    {"JAVA101", "What is the default scope of a JSP bean?", "page"},
                    {"JAVA101", "Which method destroys a session in Java?", "session.invalidate()"},
                    {"JAVA101", "What does JSP stand for?", "JavaServer Pages"},
                    {"JAVA101", "Which object allows sharing data across the entire web application?", "ServletContext"},
                    {"JAVA101", "Which HTTP method is used to request data from a specified resource?", "GET"},
                    {"JAVA101", "Which HTTP method is used to send data to a server to create/update a resource?", "POST"},
                    {"JAVA101", "Which implicitly available object represents the HTTP request in JSP?", "request"},
                    {"JAVA101", "Which file serves as the deployment descriptor in a Java web application?", "web.xml"},
                    {"JAVA101", "What is the lifecycle method called when a servlet is first created?", "init()"},
                    {"JAVA101", "What is the lifecycle method called to handle client requests in a servlet?", "service()"},
                    {"JAVA101", "Which implicitly available object represents the HTTP response in JSP?", "response"},
                    {"JAVA101", "What package contains the classes required for Java servlets?", "javax.servlet"},
                    {"JAVA101", "Which JSP tag is used to evaluate a Java expression and output the result?", "<%= %>"},
                    {"JAVA101", "Which tag library provides standard control flow and formatting tags in JSP?", "JSTL"},
                    {"JAVA101", "What pattern separates application data, UI, and control logic?", "MVC"},
                    {"JAVA101", "In MVC, what role does a Servlet typically play?", "Controller"},
                    {"JAVA101", "What method is used to redirect a user to a different URL?", "response.sendRedirect()"},
                    {"JAVA101", "What method is used to forward a request to another resource internally?", "RequestDispatcher.forward()"},
                    {"JAVA101", "Which object provides initialization parameters to a specific servlet?", "ServletConfig"},

                    // DEV201
                    {"DEV201", "Which tool is the industry standard for containerization?", "Docker"},
                    {"DEV201", "In the acronym CI/CD, what does CI stand for?", "Continuous Integration"},
                    {"DEV201", "In the acronym CI/CD, what does CD stand for?", "Continuous Deployment"},
                    {"DEV201", "Which declarative configuration tool is used to orchestrate containers?", "Kubernetes"},
                    {"DEV201", "What is the standard configuration file used to build a Docker image?", "Dockerfile"},
                    {"DEV201", "Which tool is commonly used for Infrastructure as Code (IaC)?", "Terraform"},
                    {"DEV201", "What version control system is distributed and relies on commits?", "Git"},
                    {"DEV201", "Which platform provides web-based Git repository hosting and CI/CD actions?", "GitHub"},
                    {"DEV201", "What term describes a lightweight, standalone, executable package of software?", "Container"},
                    {"DEV201", "What architectural style structures an application as a collection of loosely coupled services?", "Microservices"},
                    {"DEV201", "Which AWS service is commonly used for scalable compute capacity?", "EC2"},
                    {"DEV201", "What is the practice of managing servers through machine-readable definition files?", "Infrastructure as Code"},
                    {"DEV201", "Which automation server relies on a Jenkinsfile for CI/CD pipelines?", "Jenkins"},
                    {"DEV201", "What monitoring tool uses a time-series database to track metrics?", "Prometheus"},
                    {"DEV201", "What tool is commonly paired with Prometheus for data visualization?", "Grafana"},
                    {"DEV201", "What Linux command is used to change file permissions?", "chmod"},
                    {"DEV201", "Which configuration management tool uses playbooks written in YAML?", "Ansible"},
                    {"DEV201", "What command downloads a Docker image from a registry?", "docker pull"},
                    {"DEV201", "What process involves finding and fixing errors in infrastructure or code?", "Debugging"},
                    {"DEV201", "What strategy slowly rolls out a new software version to a small subset of users?", "Canary Release"},

                    // PYT301
                    {"PYT301", "What keyword is used to define a function in Python?", "def"},
                    {"PYT301", "Which data structure uses key-value pairs?", "Dictionary"},
                    {"PYT301", "What data type is immutable and ordered?", "Tuple"},
                    {"PYT301", "What data type is mutable and ordered?", "List"},
                    {"PYT301", "What function is used to output text to the console?", "print()"},
                    {"PYT301", "What keyword is used to handle exceptions in Python?", "except"},
                    {"PYT301", "What keyword is used to import a module?", "import"},
                    {"PYT301", "What method adds an item to the end of a list?", "append()"},
                    {"PYT301", "Which built-in function returns the number of items in an object?", "len()"},
                    {"PYT301", "What symbol is used to comment a single line in Python?", "#"},
                    {"PYT301", "What keyword is used to return a value from a function?", "return"},
                    {"PYT301", "Which module is commonly used for generating random numbers?", "random"},
                    {"PYT301", "What object-oriented concept allows a class to derive from another class?", "Inheritance"},
                    {"PYT301", "What is the standard package manager for Python?", "pip"},
                    {"PYT301", "Which operator is used for exponentiation?", "**"},
                    {"PYT301", "What boolean value represents false in Python?", "False"},
                    {"PYT301", "Which loop executes a block of code as long as a condition is true?", "while"},
                    {"PYT301", "What function is used to get user input from the console?", "input()"},
                    {"PYT301", "What special method initializes a new object instance?", "__init__"},
                    {"PYT301", "What library is the industry standard for data manipulation and analysis?", "pandas"},

                    // AGI401
                    {"AGI401", "What is the time-boxed iteration in Scrum called?", "Sprint"},
                    {"AGI401", "Who is responsible for maximizing the value of the product in Scrum?", "Product Owner"},
                    {"AGI401", "Who facilitates the Scrum process and removes impediments?", "Scrum Master"},
                    {"AGI401", "What is the daily 15-minute sync meeting called?", "Daily Standup"},
                    {"AGI401", "What artifact holds the prioritized list of requirements?", "Product Backlog"},
                    {"AGI401", "What artifact holds the tasks committed for the current iteration?", "Sprint Backlog"},
                    {"AGI401", "What meeting occurs at the end of a sprint to reflect on what went well?", "Sprint Retrospective"},
                    {"AGI401", "What meeting occurs at the end of a sprint to demonstrate the working software?", "Sprint Review"},
                    {"AGI401", "What unit of measurement is often used to estimate user stories?", "Story Points"},
                    {"AGI401", "What visual board uses columns like To Do, In Progress, and Done?", "Kanban Board"},
                    {"AGI401", "What metric measures the amount of work completed in a sprint?", "Velocity"},
                    {"AGI401", "What chart tracks remaining work over time?", "Burndown Chart"},
                    {"AGI401", "What document outlines the core values and principles of Agile?", "Agile Manifesto"},
                    {"AGI401", "What is a small, functional slice of software delivered to a user called?", "Increment"},
                    {"AGI401", "What technique is used by teams to estimate effort using cards?", "Planning Poker"},
                    {"AGI401", "What term describes work that must be completed to ensure quality (e.g., refactoring)?", "Technical Debt"},
                    {"AGI401", "What format follows \"As a [role], I want [goal] so that [benefit]\"?", "User Story"},
                    {"AGI401", "What defines the shared understanding of what it means for work to be complete?", "Definition of Done"},
                    {"AGI401", "Which scaling framework adapts Scrum for large enterprises?", "SAFe"},
                    {"AGI401", "What term refers to changing requirements late in development?", "Scope Creep"},

                    // ITIL501
                    {"ITIL501", "What does ITIL stand for?", "Information Technology Infrastructure Library"},
                    {"ITIL501", "What is the core concept of ITIL 4 that converts demand into value?", "Service Value System"},
                    {"ITIL501", "What ITIL practice manages workarounds and known errors?", "Problem Management"},
                    {"ITIL501", "What ITIL practice restores normal service operation as quickly as possible?", "Incident Management"},
                    {"ITIL501", "What is an unplanned interruption to a service called?", "Incident"},
                    {"ITIL501", "What is the cause of one or more incidents?", "Problem"},
                    {"ITIL501", "What entity acts as the single point of contact between the service provider and users?", "Service Desk"},
                    {"ITIL501", "What is the addition, modification, or removal of anything affecting services?", "Change"},
                    {"ITIL501", "What ITIL practice ensures services meet agreed-upon performance targets?", "Service Level Management"},
                    {"ITIL501", "What agreement documents the performance targets between provider and customer?", "SLA"},
                    {"ITIL501", "What term describes the perceived benefits, usefulness, and importance of something?", "Value"},
                    {"ITIL501", "What guiding principle suggests starting with what currently exists?", "Start where you are"},
                    {"ITIL501", "What guiding principle focuses on breaking work into manageable chunks?", "Progress iteratively with feedback"},
                    {"ITIL501", "What dimension of service management includes roles, skills, and culture?", "Organizations and people"},
                    {"ITIL501", "What dimension includes workflows, controls, and procedures?", "Value streams and processes"},
                    {"ITIL501", "What term describes ensuring a service is fit for purpose?", "Utility"},
                    {"ITIL501", "What term describes ensuring a service is fit for use (e.g., available, secure)?", "Warranty"},
                    {"ITIL501", "What is a formal request from a user for something to be provided?", "Service Request"},
                    {"ITIL501", "What is any component that needs to be managed to deliver an IT service?", "Configuration Item"},
                    {"ITIL501", "What database stores information about Configuration Items and their relationships?", "CMDB"},

                    // SEC601
                    {"SEC601", "What principle ensures data is accessible only to authorized individuals?", "Confidentiality"},
                    {"SEC601", "What principle ensures data is accurate and untampered?", "Integrity"},
                    {"SEC601", "What principle ensures systems and data are accessible when needed?", "Availability"},
                    {"SEC601", "What type of malware demands payment to unlock encrypted files?", "Ransomware"},
                    {"SEC601", "What social engineering attack uses deceptive emails to steal credentials?", "Phishing"},
                    {"SEC601", "What attack floods a system with traffic to make it unavailable?", "DDoS"},
                    {"SEC601", "What network security system monitors and controls incoming and outgoing traffic?", "Firewall"},
                    {"SEC601", "What mechanism converts plaintext into unreadable ciphertext?", "Encryption"},
                    {"SEC601", "What technique verifies the identity of a user?", "Authentication"},
                    {"SEC601", "What technique determines what an authenticated user is allowed to do?", "Authorization"},
                    {"SEC601", "What security model assumes no implicit trust, regardless of network location?", "Zero Trust"},
                    {"SEC601", "What process disguises IP addresses by translating private IPs to a public IP?", "NAT"},
                    {"SEC601", "What creates a secure, encrypted connection over a less secure network?", "VPN"},
                    {"SEC601", "What type of software is designed to detect, prevent, and remove malicious software?", "Antivirus"},
                    {"SEC601", "What vulnerability allows an attacker to inject malicious scripts into a web page?", "XSS"},
                    {"SEC601", "What vulnerability allows an attacker to execute unauthorized database queries?", "SQL Injection"},
                    {"SEC601", "What process identifies, evaluates, and mitigates risks to IT assets?", "Risk Management"},
                    {"SEC601", "What term describes a weakness in a system that could be exploited?", "Vulnerability"},
                    {"SEC601", "What term describes a newly discovered vulnerability with no available patch?", "Zero Day"},
                    {"SEC601", "What authentication method requires two or more pieces of evidence?", "MFA"},

                    // CMP701
                    {"CMP701", "What does RAM stand for?", "Random Access Memory"},
                    {"CMP701", "What component is considered the brain of the computer?", "CPU"},
                    {"CMP701", "What type of storage has no moving parts and uses flash memory?", "SSD"},
                    {"CMP701", "Which motherboard component connects the CPU to high-speed components like RAM?", "Northbridge"},
                    {"CMP701", "What firmware interface replaced traditional BIOS?", "UEFI"},
                    {"CMP701", "What hardware component provides power to the motherboard and internal devices?", "PSU"},
                    {"CMP701", "What is the standard connector for wired Ethernet networks?", "RJ-45"},
                    {"CMP701", "What command-line tool verifies IP-level connectivity to another device?", "ping"},
                    {"CMP701", "What command shows the IP address configuration in Windows?", "ipconfig"},
                    {"CMP701", "What command shows the MAC address and network interfaces in Linux?", "ifconfig"},
                    {"CMP701", "What protocol automatically assigns IP addresses to devices?", "DHCP"},
                    {"CMP701", "What protocol resolves domain names to IP addresses?", "DNS"},
                    {"CMP701", "What port does HTTP use by default?", "80"},
                    {"CMP701", "What port does HTTPS use by default?", "443"},
                    {"CMP701", "What port does SSH use by default?", "22"},
                    {"CMP701", "What type of printer uses toner and a laser beam?", "Laser Printer"},
                    {"CMP701", "What built-in Windows utility is used to manage partitions and drives?", "Disk Management"},
                    {"CMP701", "What feature allows a device to be added or removed while the computer is running?", "Hot Swapping"},
                    {"CMP701", "What wireless standard operates at both 2.4 GHz and 5 GHz?", "802.11ac"},
                    {"CMP701", "What tool is used to attach RJ-45 connectors to twisted-pair cables?", "Crimper"},

                    // CMP801
                    {"CMP801", "What cryptographic concept ensures a sender cannot deny sending a message?", "Non-repudiation"},
                    {"CMP801", "What mathematical function converts data into a fixed-size string of characters?", "Hashing"},
                    {"CMP801", "Which hashing algorithm produces a 256-bit digest?", "SHA-256"},
                    {"CMP801", "What infrastructure manages the creation, storage, and distribution of digital certificates?", "PKI"},
                    {"CMP801", "What type of key cryptography uses a public key and a private key?", "Asymmetric Encryption"},
                    {"CMP801", "What protocol encrypts web traffic?", "HTTPS"},
                    {"CMP801", "What device acts as an intermediary for requests from clients seeking resources?", "Proxy Server"},
                    {"CMP801", "What physical security mechanism uses two doors to prevent tailgating?", "Mantrap"},
                    {"CMP801", "What logical security concept gives users only the permissions necessary to do their job?", "Least Privilege"},
                    {"CMP801", "What is a decoy system designed to attract and analyze attackers?", "Honeypot"},
                    {"CMP801", "What testing method simulates a cyber attack to find vulnerabilities?", "Penetration Testing"},
                    {"CMP801", "What type of malware is hidden inside seemingly legitimate software?", "Trojan"},
                    {"CMP801", "What protocol provides secure remote command-line access to a server?", "SSH"},
                    {"CMP801", "What attack intercepts communication between two parties without their knowledge?", "Man-in-the-Middle"},
                    {"CMP801", "What attack involves trying every possible password combination?", "Brute Force"},
                    {"CMP801", "What policy outlines acceptable use of company assets by employees?", "AUP"},
                    {"CMP801", "What type of backup copies all files that have changed since the last full backup?", "Differential Backup"},
                    {"CMP801", "What control type prevents an incident from occurring (e.g., a firewall)?", "Preventive"},
                    {"CMP801", "What control type identifies an incident after it has occurred (e.g., an IDS)?", "Detective"},
                    {"CMP801", "What protocol secures wireless networks and replaced WPA2?", "WPA3"},

                    // CMP901
                    {"CMP901", "What does IT stand for?", "Information Technology"},
                    {"CMP901", "What is the physical equipment of a computer system called?", "Hardware"},
                    {"CMP901", "What term refers to the programs and operating systems used by computers?", "Software"},
                    {"CMP901", "Which computing model delivers services like storage and processing over the internet?", "Cloud Computing"},
                    {"CMP901", "What type of cloud service provides a complete application over the internet?", "SaaS"},
                    {"CMP901", "What type of cloud service provides virtualized hardware resources over the internet?", "IaaS"},
                    {"CMP901", "What technology creates a virtual version of a physical server or operating system?", "Virtualization"},
                    {"CMP901", "What is the global network of interconnected devices that communicate via sensors?", "IoT"},
                    {"CMP901", "What does OS stand for?", "Operating System"},
                    {"CMP901", "Which OS is known for being open-source and highly customizable?", "Linux"},
                    {"CMP901", "What file format is commonly used to distribute read-only documents?", "PDF"},
                    {"CMP901", "What is the fundamental unit of data in computing, representing a 0 or 1?", "Bit"},
                    {"CMP901", "How many bits make up a byte?", "8"},
                    {"CMP901", "What is a unique identifier assigned to a network interface controller?", "MAC Address"},
                    {"CMP901", "What technology uses radio waves for local area networking?", "Wi-Fi"},
                    {"CMP901", "What standard defines short-range wireless communication between devices?", "Bluetooth"},
                    {"CMP901", "What type of backup stores data on physical media like magnetic tape?", "Tape Backup"},
                    {"CMP901", "What software protects a computer from viruses and malware?", "Antivirus"},
                    {"CMP901", "What is the process of creating a replica of data for recovery purposes?", "Backup"},
                    {"CMP901", "What device connects multiple networks and directs data packets between them?", "Router"},

                    // PBI101
                    {"PBI101", "Which Power BI component is used primarily for creating desktop reports?", "Power BI Desktop"},
                    {"PBI101", "Which tool within Power BI is used to clean and transform data?", "Power Query"},
                    {"PBI101", "What expression language is used in Power BI for custom calculations?", "DAX"},
                    {"PBI101", "What is a collection of visuals on a single page in Power BI called?", "Dashboard"},
                    {"PBI101", "What visualization type is best for showing data over time?", "Line Chart"},
                    {"PBI101", "What visualization type is best for comparing categories?", "Bar Chart"},
                    {"PBI101", "What feature connects two tables based on a common column?", "Relationship"},
                    {"PBI101", "Which relationship cardinality is the most common and recommended?", "One-to-Many"},
                    {"PBI101", "What DAX function is used to aggregate a column based on a filter condition?", "CALCULATE"},
                    {"PBI101", "What pane allows you to drag and drop fields to build visuals?", "Fields Pane"},
                    {"PBI101", "What visual filters data on a report page directly via a user interface?", "Slicer"},
                    {"PBI101", "What file extension is used for Power BI Desktop files?", ".pbix"},
                    {"PBI101", "What Power BI service feature refreshes data automatically on a schedule?", "Scheduled Refresh"},
                    {"PBI101", "What tool allows Power BI Service to connect to on-premises data sources?", "Data Gateway"},
                    {"PBI101", "What is a single visual element on a dashboard called?", "Tile"},
                    {"PBI101", "What view in Power BI Desktop shows the relationships between tables?", "Model View"},
                    {"PBI101", "What view displays the raw data within your tables?", "Data View"},
                    {"PBI101", "What DAX function returns the total number of rows in a table?", "COUNTROWS"},
                    {"PBI101", "What DAX function creates a running total or calculates across a date range?", "TOTALYTD"},
                    {"PBI101", "What feature uses AI to allow users to ask questions about their data using natural language?", "Q&A"},

                    // AZU111
                    {"AZU111", "What is Microsoft's public cloud computing platform called?", "Azure"},
                    {"AZU111", "Which service is used to manage identities and access in Azure?", "Microsoft Entra ID"},
                    {"AZU111", "What Azure compute service provides virtualized servers?", "Azure Virtual Machines"},
                    {"AZU111", "What serverless compute service runs code without provisioning infrastructure?", "Azure Functions"},
                    {"AZU111", "What storage service is highly scalable and used for storing unstructured data?", "Azure Blob Storage"},
                    {"AZU111", "What logic concept organizes Azure resources into a single manageable unit?", "Resource Group"},
                    {"AZU111", "What global infrastructure concept consists of a set of datacenters in a specific area?", "Region"},
                    {"AZU111", "What physical locations provide high availability within an Azure region?", "Availability Zones"},
                    {"AZU111", "What type of database service does Azure SQL Database provide?", "PaaS"},
                    {"AZU111", "What Azure service provides a private network in the cloud?", "Azure Virtual Network"},
                    {"AZU111", "What tool helps estimate the cost of Azure resources before deployment?", "Pricing Calculator"},
                    {"AZU111", "What dashboard provides personalized recommendations to optimize Azure resources?", "Azure Advisor"},
                    {"AZU111", "What service protects Azure applications against Distributed Denial of Service attacks?", "Azure DDoS Protection"},
                    {"AZU111", "What feature allows you to enforce rules and compliance across Azure resources?", "Azure Policy"},
                    {"AZU111", "What cloud model involves keeping some resources on-premises and some in Azure?", "Hybrid Cloud"},
                    {"AZU111", "What is the primary management interface for Azure resources?", "Azure Portal"},
                    {"AZU111", "What command-line interface is used to manage Azure resources?", "Azure CLI"},
                    {"AZU111", "What expenditure model describes cloud computing's pay-as-you-go structure?", "OpEx"},
                    {"AZU111", "What expenditure model describes buying physical hardware upfront?", "CapEx"},
                    {"AZU111", "What Azure service provides a managed NoSQL database?", "Azure Cosmos DB"},

                    // SQL121
                    {"SQL121", "What does SQL stand for?", "Structured Query Language"},
                    {"SQL121", "Which clause is used to filter records in a SELECT statement?", "WHERE"},
                    {"SQL121", "Which keyword is used to retrieve only distinct values?", "DISTINCT"},
                    {"SQL121", "Which keyword sorts the result set?", "ORDER BY"},
                    {"SQL121", "Which keyword sorts the result set in descending order?", "DESC"},
                    {"SQL121", "Which aggregate function returns the total number of rows?", "COUNT()"},
                    {"SQL121", "Which aggregate function returns the highest value in a column?", "MAX()"},
                    {"SQL121", "Which aggregate function adds all values in a numeric column?", "SUM()"},
                    {"SQL121", "Which clause groups rows that have the same values into summary rows?", "GROUP BY"},
                    {"SQL121", "Which clause is used to filter groups created by GROUP BY?", "HAVING"},
                    {"SQL121", "What type of JOIN returns records that have matching values in both tables?", "INNER JOIN"},
                    {"SQL121", "What type of JOIN returns all records from the left table, and matched records from the right?", "LEFT JOIN"},
                    {"SQL121", "What operator is used to search for a specified pattern in a column?", "LIKE"},
                    {"SQL121", "What wildcard character represents zero or more characters in a LIKE statement?", "%"},
                    {"SQL121", "What SQL statement is used to add new rows of data to a table?", "INSERT INTO"},
                    {"SQL121", "What SQL statement is used to modify existing data in a table?", "UPDATE"},
                    {"SQL121", "What SQL statement is used to remove data from a table?", "DELETE"},
                    {"SQL121", "What constraint ensures a column cannot have a NULL value?", "NOT NULL"},
                    {"SQL121", "What constraint uniquely identifies each record in a table?", "PRIMARY KEY"},
                    {"SQL121", "What constraint links two tables together to maintain referential integrity?", "FOREIGN KEY"}
                };

                // Map questions to the precise auto-increment database key
                for (String[] q : rawQuestions) {
                    String courseCodeKey = q[0];
                    Integer generatedId = courseIdMap.get(courseCodeKey);
                    
                    if (generatedId != null) {
                        pstmtQuestion.setInt(1, generatedId);
                        pstmtQuestion.setString(2, q[1]);
                        pstmtQuestion.setString(3, q[2]);
                        pstmtQuestion.addBatch();
                    }
                }
                pstmtQuestion.executeBatch();

                // Synchronize the sequence counter safely for subsequent manual inserts
                stmtSeq.execute("SELECT setval(pg_get_serial_sequence('Courses', 'course_id'), COALESCE((SELECT MAX(course_id)+1 FROM Courses), 1), false)");

                conn.commit();
                statusMessage.append("PostgreSQL (12 Courses + 240 Qs) OK!");

            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            }

        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR during PostgreSQL Seeding: " + e.getMessage();
        }

        return statusMessage.toString();
    }
}