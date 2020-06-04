package stuff;

import com.opencsv.CSVReader;

import java.io.BufferedReader;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import static java.lang.System.exit;

/**
 * Collect all data known about a accession_number on a single line
 */
public class Samenvoeger {
    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("Usage: java stuff.Samenvoeger <csv filename>");
            exit(-1);
        }
        String filename = args[0];
        Map<String, SamenvoegerResult> result = new HashMap<>();
        String[] data;
        try (CSVReader csvReader = new CSVReader(new BufferedReader(new FileReader(filename)), ';', '"', 1)) {
            while ((data = csvReader.readNext()) != null) {
                String accessionNumber = data[4];
                SamenvoegerResult current = result.getOrDefault(accessionNumber, new SamenvoegerResult(accessionNumber));
                result.put(accessionNumber, current);
                current.geneNames.add(data[0]);
                current.proteinNames.add(data[1]);
                current.ksmbrNumbers.add(data[2]);
                current.kustNumbers.add(data[3]);
            }
        }

        FileOutputStream fos = new FileOutputStream("conversion_table5_samengevoegd.csv");
        result.values().forEach(line -> printALine(fos, line));
        fos.close();
    }

    private static void printALine(FileOutputStream fos, SamenvoegerResult samenvoegerResult) {
        try {
            fos.write((samenvoegerResult.toCsv() + "\n").getBytes());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}

class SamenvoegerResult {
    public final String accessionNumber;
    public final Set<String> geneNames = new HashSet<>();
    public final Set<String> proteinNames = new HashSet<>();
    public final Set<String> ksmbrNumbers = new HashSet<>();
    public final Set<String> kustNumbers = new HashSet<>();

    public SamenvoegerResult(String accessionNumber) {
        this.accessionNumber = accessionNumber;
    }

    public String toCsv() {
        StringBuilder sb = new StringBuilder();
        geneNames.forEach(value -> sb.append(value).append(' '));
        sb.append(';');
        StringBuilder pnames = new StringBuilder();
        proteinNames.forEach(value -> pnames.append(value).append(','));
        String pnamesAsString = pnames.toString();
        pnamesAsString = pnamesAsString.substring(0, pnames.length() - 1);
        sb.append("\"").append(pnamesAsString).append("\";");

        ksmbrNumbers.forEach(value -> sb.append(value).append(' '));
        sb.append(';');
        kustNumbers.forEach(value -> sb.append(value).append(' '));
        sb.append(';').append(accessionNumber);
        return sb.toString().replaceAll(" ;", ";").replaceAll(",;", ";");
    }
}
