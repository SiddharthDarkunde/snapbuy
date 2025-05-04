<%@ page import="java.sql.*" %>
<%
    String dbURL = "jdbc:postgresql://localhost:5432/java";
    String dbUser = "postgres";
    String dbPass = "1234";

    String message = "";

    if (request.getMethod().equalsIgnoreCase("POST")) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Sanitize the name to create a safe table name
        String safeTableName = name.replaceAll("[^a-zA-Z0-9_]", "_");

        try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
            Statement stmt = conn.createStatement();

            // 1. Create register table with name
            String createRegisterTable = "CREATE TABLE IF NOT EXISTS register (" +
                    "name VARCHAR(255) PRIMARY KEY," +
                    "email VARCHAR(255) NOT NULL," +
                    "password VARCHAR(255) NOT NULL)";
            stmt.executeUpdate(createRegisterTable);

            // 2. Insert user data into register table
            String insertUser = "INSERT INTO register (name, email, password) VALUES (?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(insertUser);
            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setString(3, password);
            pstmt.executeUpdate();

            // 3. Create user-specific profile table
            String createUserTable = "CREATE TABLE IF NOT EXISTS user_profile (" +
                    "id SERIAL PRIMARY KEY," +
                    "name VARCHAR(255) NOT NULL," +
                    "email VARCHAR(255) NOT NULL," +
                    "password VARCHAR(255) NOT NULL," +
                    "profile_picture VARCHAR(255)," +
                    "bio TEXT," +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
            
            // Log the query to verify it's being constructed correctly
            System.out.println("Creating user-specific table: " + createUserTable);

            // Execute the table creation query
            stmt.executeUpdate(createUserTable);

            // Insert profile data for user
            String insertProfile = "INSERT INTO user_profile (name, email, password) VALUES (?, ?, ?)";
            PreparedStatement profilePstmt = conn.prepareStatement(insertProfile);
            profilePstmt.setString(1, name);
            profilePstmt.setString(2, email);
            profilePstmt.setString(3, password);
            profilePstmt.executeUpdate();

            message = "Registration successful! Profile created for: " + name;

            pstmt.close();
            profilePstmt.close();
            stmt.close();
            conn.close();
        } catch (SQLException e) {
            if (e.getSQLState().equals("23505")) {
                message = "Email already registered!";
            } else {
                message = "Error: " + e.getMessage();
            }
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
        }
    }
%>

<p id="message" style="color: red; text-align: center; margin-top: 10px;">
    <%= message %>
</p>

<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Register Page</title>
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            font-family: "Trebuchet MS", "Lucida Sans Unicode", "Lucida Grande", "Lucida Sans", Arial, sans-serif;
        }

        section {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            width: 100%;
           background: url("img/aaa.jpg") no-repeat;
        }

        .form-box {
            position: relative;
            width: 450px;
            height: auto;
            background: transparent;
            border: 1px solid #fefefe;
            border-radius: 20px;
            backdrop-filter: blur(10px) brightness(70%);
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 30px 0;
        }

        h2 {
            font-size: 2em;
            color: #fff;
            text-align: center;
        }

        .inputbox {
            position: relative;
            margin: 30px auto;
            width: 310px;
            border-bottom: 2px solid #fff;
        }

        .inputbox label {
            position: absolute;
            top: 50%;
            left: 5px;
            transform: translateY(-50%);
            color: #fff;
            font-size: 1em;
            pointer-events: none;
            transition: 0.5s;
        }

        input:focus ~ label,
        input:valid ~ label {
            top: -5px;
        }

        .inputbox input {
            width: 100%;
            height: 50px;
            background: transparent;
            border: none;
            outline: none;
            font-size: 1em;
            padding: 0 35px 0 5px;
            color: #fff;
        }

        .inputbox ion-icon {
            position: absolute;
            right: 8px;
            color: #fff;
            font-size: 1.2em;
            top: 20px;
        }

        button, .btn-alt {
            width: 100%;
            height: 40px;
            border-radius: 40px;
            background-color: #fff;
            border: none;
            outline: none;
            cursor: pointer;
            font-size: 1em;
            font-weight: 600;
            margin-top: 10px;
        }

        .btn-alt {
            background-color: transparent;
            color: #fff;
            border: 1px solid #fff;
        }

        .btn-alt:hover {
            background-color: #fff;
            color: black;
        }

        @media screen and (max-width: 480px) {
            .form-box {
                width: 100%;
                border-radius: 0px;
            }
        }
    </style>
</head>

<body>
    <section>
        <div class="form-box">
            <div class="form-value">
                <form method="post">
                    <h2>Register</h2>

                    <div class="inputbox">
                        <ion-icon name="person-outline"></ion-icon>
                        <input type="text" name="name" required>
                        <label>Name</label>
                    </div>

                    <div class="inputbox">
                        <ion-icon name="mail-outline"></ion-icon>
                        <input type="email" name="email" required>
                        <label>Email</label>
                    </div>

                    <div class="inputbox">
                        <ion-icon name="lock-closed-outline"></ion-icon>
                        <input type="password" name="password" required>
                        <label>Password</label>
                    </div>

                    <button type="submit">Register</button>
                    <button type="button" class="btn-alt" onclick="window.location.href='login.jsp'">Login</button>

                    <% if (!message.isEmpty()) { %>
                    <div style="margin-top: 20px; padding: 12px 20px; background-color: #d4edda; border-left: 6px solid #28a745; color: #155724; font-weight: bold; text-align: center; border-radius: 5px;">
                   <%= message %>
                    </div>
                    <% } %>

                </form>
            </div>
        </div>
    </section>
</body>
</html>
