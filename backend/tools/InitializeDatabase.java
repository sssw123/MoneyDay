import java.nio.file.*;
import java.sql.*;
import java.util.Properties;

/** Run with the MySQL driver on the classpath. All credentials come from environment variables. */
public class InitializeDatabase {
    public static void main(String[] args) throws Exception {
        String url=required("MONEYDAY_DB_URL");
        String name=url.replaceFirst("^jdbc:mysql://[^/]+/","").split("\\?",2)[0];
        if(!name.matches("moneyday_multiuser|moneyday_test_[a-zA-Z0-9_]+")) throw new IllegalArgumentException("Only moneyday_multiuser or moneyday_test_* may be initialized");
        Properties config=new Properties();config.setProperty("user",required("MONEYDAY_DB_USERNAME"));config.setProperty("password",required("MONEYDAY_DB_PASSWORD"));
        String server=url.replaceFirst("/"+name+"(?=\\?|$)","/");
        try(Connection connection=DriverManager.getConnection(server,config);Statement sql=connection.createStatement()) {
            try(ResultSet lock=sql.executeQuery("SELECT GET_LOCK('moneyday_init_"+name+"',10)")) {lock.next();if(lock.getInt(1)!=1)throw new IllegalStateException("Initialization already running");}
            try(PreparedStatement check=connection.prepareStatement("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=?")) {
                check.setString(1,name);try(ResultSet result=check.executeQuery()) {result.next();if(result.getInt(1)!=0)throw new IllegalStateException("Target schema is not empty; initialization stopped");}
            }
            sql.executeUpdate("CREATE DATABASE IF NOT EXISTS `"+name+"` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            sql.execute("USE `"+name+"`");
            String ddl=Files.readString(Path.of(args.length==0?"src/main/resources/schema.sql":args[0])).replaceAll("(?m)^--.*$","");
            for(String statement:ddl.split(";")) if(!statement.isBlank()) sql.execute(statement);
            System.out.println("Initialized empty schema: "+name);
        } catch(SQLException e) {
            System.err.println("Database initialization failed; SQLState="+e.getSQLState()+", code="+e.getErrorCode()+". Existing source schema was not modified.");
            System.exit(1);
        }
    }
    private static String required(String name) {String value=System.getenv(name);if(value==null || value.isBlank())throw new IllegalArgumentException("Missing environment variable "+name);return value;}
}
