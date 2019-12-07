package SplitCSV;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner;
public class SplitCSV {
	
	private int counter;
	public static void main(String[] args) {
		SplitCSV sc = new SplitCSV();
		sc.counter = new File("/Users/arnavreddy/eclipse-workspace/WebTesting/src/SplitCSV/Testing Set/Shooting a Basketball").listFiles().length;
		sc.readCSV("/Users/arnavreddy/eclipse-workspace/WebTesting/src/SplitCSV/" + "input" + ".csv");
	}
	
	public void readCSV(String fileName)
	{
		Scanner infile = null;
		String chunk = "";
		
		try
		{
			infile = new Scanner(new File(fileName));
		}
		catch(FileNotFoundException e)
		{
			System.out.print("Oh noes");
		}
		
		String temp = "";
		while(infile.hasNext())
		{
			temp += infile.nextLine()+"\n";
		}
		infile.close();
		
		while(true)
		{
			int nextIndex = temp.indexOf("Time", 10);
			if(nextIndex == -1) { makeCSV(temp); break; }
			chunk = temp.substring(0, nextIndex);
			makeCSV(chunk);
			temp = temp.substring(nextIndex);
		}
	}
	
	public void makeCSV(String text)
	{
		File file = new File("/Users/arnavreddy/eclipse-workspace/WebTesting/src/SplitCSV/Testing Set/Shooting a Basketball/" + "basketball" + counter + ".csv");
		try
		{
			if (file.createNewFile())
			{
			    System.out.println("basketball" + counter + ".csv created!");
			} else {
			    System.out.println("File already exists.");
			}
			FileWriter writer = new FileWriter(file);
			writer.write(text);
			writer.close();
		}
		catch(IOException e)
		{
			System.out.println("New Way Needed");
		}
		counter++;
	}
}
