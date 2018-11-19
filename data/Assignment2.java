import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        //set the search path

        //get the connection based on the credentials
        try {
            this.connection = DriverManager.getConnection(url, username, password);
        }
        catch ( SQLException err ) {
            System.out.println("Cannot connect to the database");
            return false;
        }
        return true;
    }

    @Override
    public boolean disconnectDB() {
        try {
            this.connection.close();
        }
        catch ( SQLException err ) {
            System.out.println("Could not close the database");
            return false;
        }
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {

        try {
            Statement statement = connection.createStatement();
            String query = "SELECT election.id, cabinet.id " +
                    "FROM election, cabinet " +
                    "WHERE election.id = cabinet.election_id AND election.country_id = cabinet.country_id = " +
                    countryName + " " +
                    "ORDER BY election.e_date DESC";

            ResultSet set = statement.executeQuery(query);

            //loop through the result set and return a 2d array which is an ElectionCabinetResult
            //create to arrays then feed into ElectionCabinetResult
            ArrayList<Integer> cabinet = new ArrayList<>();
            ArrayList<Integer> election = new ArrayList<>();

            while (set.next()) {
                election.add(set.getInt(1));
                cabinet.add(set.getInt(2));
            }
            return new ElectionCabinetResult(election, cabinet);
        } catch (SQLException e){
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        ArrayList<Integer> output = new ArrayList<>();
        try {
            Statement statement = connection.createStatement();
            String query = "SELECT p2.id, p1.description || ' ' || p1.comments as compare1, p2.description || ' ' ||" +
                    " p2.comments as compare2 " +
                    "FROM politician_president p1, politician president p2 " +
                    "WHERE p1.id = " + politicianName + " AND p1.id < p2.id";

            ResultSet set = statement.executeQuery(query);

            //if the description and comments pass the threshold, then retain the id of the second politician
            while (set.next()) {
                if (similarity(set.getString(2), set.getString(3)) > threshold){
                    output.add(set.getInt(1));
                }
            }
            return output;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
    }

}

