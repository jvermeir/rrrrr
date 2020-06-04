package stuff;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class X {
    public static void main(String[] args) throws Exception {
        BufferedReader csvReader = new BufferedReader(new FileReader("data/uniprot_acc_ksmbr.csv"));
        String row;
        List<Result> res = new ArrayList<>();
        while ((row = csvReader.readLine()) != null) {
            String[] data = row.split(";");
            if (data[1].indexOf(' ') > 0) {
                String[] ksmbrs = data[1].split(" ");
                for (String ksmbr : ksmbrs) {
                    res.add(new Result(data[0], ksmbr));
                }
            } else {
                res.add(new Result(data[0], data[1]));
            }
        }
        csvReader.close();
        res.forEach(x -> System.out.println(x.toCsv()));
        Set<String> set = res.stream().map(x -> x.ksmbr_number).collect(Collectors.toSet());
        System.out.println("list: " + res.size() + " set " + set.size());

    }

}
class Result {
    public final String accession_number;
    public final String ksmbr_number;

    public String toCsv() {
        return ksmbr_number + ";" + accession_number;
    }

    @Override
    public String toString() {
        return "stuff.Result{" +
                "accession_number='" + accession_number + '\'' +
                ", ksmbr_number='" + ksmbr_number + '\'' +
                '}';
    }

    public Result(String accession_number, String ksmbr_number) {
        this.accession_number = accession_number;
        this.ksmbr_number = ksmbr_number;
    }

}
