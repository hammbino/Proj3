package com.desktop.Tutorial;

import java.io.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.*;

import static java.util.regex.Pattern.matches;

public class Main {
    private static final int INT_SIZE = 4, BYTE_SIZE = 1;
    private static int mem_location = 0, beginCodeSection = 0, indirOptCodeOffset = 13;
    private static int regSize = 13;
    private static int PC = 8, SL = 9, SP = 10, FP = 11, SB = 12, INSTRUCTION_SIZE = 12;
    private static List<String> INSTRUCTIONS = new ArrayList<>(Arrays.asList("JMP", "JMR", "BNZ", "BGT", "BLT", "BRZ", "MOV", "LDA", "STR", "LDR", "STB", "LDB", "ADD", "ADI", "SUB", "MUL", "DIV", "AND", "OR", "CMP", "TRP"));
    private static List<String> DIRECTIVES = new ArrayList<>(Arrays.asList(".INT", ".BYT"));
    private static Map<String, Integer> SYM_TABLE = new HashMap<>();
    private static int[] REG = new int[regSize];
    private static int passNumber = 0;
    private static int endProg = 0;
    private static int lineNumber = 0;
    static Stack<Character> inStack = new Stack<>();

    public static void main(String[] args) {
        REG[PC] = -1;
        Scanner fileReader = null;
        int memSize = 100000;
        byte[] data = new byte[memSize];
        ByteBuffer bb = ByteBuffer.wrap(data);
        bb.order(ByteOrder.LITTLE_ENDIAN);


        // init stack REGs
        REG[SP] = memSize - INT_SIZE;
        REG[SB] = memSize - INT_SIZE;
        REG[FP] = memSize - INT_SIZE;

        if (args.length < 1) {
            System.out.println("No File was provided.");
            System.exit(0);
        }
        while (passNumber < 2) {
            try {
                fileReader = new Scanner(new FileInputStream(args[0])).useDelimiter(";|\\n|\\r");
            } catch (FileNotFoundException e) {
                System.out.println("Unable to open file " + args[0]);

                System.exit(0);
            }
            mem_location = 0;
            while (fileReader.hasNextLine()) {
                lineNumber++;
                String[] words = fileReader.nextLine().trim().split("\\s+");
//                System.out.println(words.length);
                if (words.length < 2|| words[0].equals(";")) continue; //takes care of blank lines or lines with one word
                if (passNumber == 0) {
                    int i = 0;
                    if (labelExist(words[i])) {
                        System.out.println("Duplicate Label on line : " + lineNumber);
                        System.exit(0);
                    }
                    if (isLabel(words[i])) {
                        addToSymbolTable(words);
                        ++i;
                    }
                    if (words[i].toUpperCase().equals(".INT"))
                        mem_location += INT_SIZE;    //increment for non labels whether it is a directive or instruction
                    if (words[i].toUpperCase().equals(".BYT")) mem_location += 1;
                    if ((words[i].toUpperCase().equals(".INT")) || words[i].toUpperCase().equals(".BYT")) {
                    } else {
                        if (REG[PC] == -1) {
                            REG[PC] = mem_location;
                            beginCodeSection = mem_location;
                        }
                        mem_location += INSTRUCTION_SIZE;
                        endProg = mem_location;
                    }
                }
                if (passNumber == 1) {
                    int index = 0;
                    String indirRegEx = "[rRSFP][0-7LBPC]";

                    if (isLabel(words[index])) ++index;     //increase index if has a label

                    switch (words[index]) {
                        case ".INT":
                            bb.putInt(mem_location, Integer.parseInt(words[++index]));
                            mem_location += INT_SIZE;
                            break;
                        case ".BYT":
                            switch (words[++index]) {
                                case "'\\n'":
                                    char NL = (char) 10;
                                    bb.put(mem_location, (byte) NL);
                                    mem_location += BYTE_SIZE;
                                    break;
                                case "'space'":
                                    char SP = (char) 32;
                                    bb.put(mem_location, (byte) SP);
                                    mem_location += BYTE_SIZE;
                                    break;
                                default:
//                                        System.out.println(words[index].charAt(1));
                                    bb.put(mem_location, (byte) (words[index].charAt(1)));
                                    mem_location += BYTE_SIZE;
                            }
                            break;
                        case "JMP":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("JMP") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, (SYM_TABLE.get(words[++index])));
//                            System.out.println(bb.getInt(SYM_TABLE.get(words[++index])));
                            mem_location += INT_SIZE;
                            mem_location += INT_SIZE;
                            break;
                        case "JMR":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("JMR") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            mem_location += INT_SIZE;
                            break;
                        case "BNZ":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("BNZ") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, (SYM_TABLE.get(words[++index])));
                            mem_location += INT_SIZE;
                            break;
                        case "BGT":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("BGT") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, (SYM_TABLE.get(words[++index])));
                            mem_location += INT_SIZE;
                            break;
                        case "BLT":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("BLT") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, (SYM_TABLE.get(words[++index])));
                            mem_location += INT_SIZE;
                            break;
                        case "BRZ":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("BRZ") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, (SYM_TABLE.get(words[++index])));
                            mem_location += INT_SIZE;
                            break;
                        case "MOV":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("MOV") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            break;
                        case "LDA":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("LDA") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            // CHECK  TO SEE IF THE ADDRESS IS IN THE CODE SECTION
//                            System.out.println(SYM_TABLE.get(words[++index]));
                            if (!(SYM_TABLE.get(words[++index]) < beginCodeSection)) {
                                System.out.println("LDA incorrect use : " + lineNumber);
                                System.exit(0);
                            }

                            bb.putInt(mem_location, (SYM_TABLE.get(words[index])));
                            mem_location += INT_SIZE;
                            break;
                        case "STR":
                            if (matches(indirRegEx, words[index + 2])) {
                                bb.putInt(mem_location, INSTRUCTIONS.indexOf("STR") + 1 + indirOptCodeOffset);
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, getReg(words[++index]));
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, getReg(words[++index]));
                                mem_location += INT_SIZE;
                            } else if (SYM_TABLE.containsKey(words[index + 2])) {
                                bb.putInt(mem_location, INSTRUCTIONS.indexOf("STR") + 1);
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, getReg(words[++index]));
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, (SYM_TABLE.get(words[++index])));
                                mem_location += INT_SIZE;
                            } else {
                                System.out.println("Bad 2nd value in STR command on line : " + lineNumber);
                            }
                            break;
                        case "LDR":
                            if (matches(indirRegEx, words[index + 2])) {
                                bb.putInt(mem_location, INSTRUCTIONS.indexOf("LDR") + 1 + indirOptCodeOffset);
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, getReg(words[++index]));
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, getReg(words[++index]));
                                mem_location += INT_SIZE;
                            } else if (SYM_TABLE.containsKey(words[index + 2])) {
                                bb.putInt(mem_location, INSTRUCTIONS.indexOf("LDR") + 1);
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, getReg(words[++index]));
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, (SYM_TABLE.get(words[++index])));
                                mem_location += INT_SIZE;
                            } else {
                                System.out.println("Bad 2nd value in LDR command on line : " + lineNumber);
                            }
                            break;
                        case "STB":
                            if (matches(indirRegEx, words[index + 2])) {
                                bb.putInt(mem_location, INSTRUCTIONS.indexOf("STB") + 1 + indirOptCodeOffset);
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, getReg(words[++index]));
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, getReg(words[++index]));
                                mem_location += INT_SIZE;
                            } else if (SYM_TABLE.containsKey(words[index + 2])) {
                                bb.putInt(mem_location, INSTRUCTIONS.indexOf("STB") + 1);
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, getReg(words[++index]));
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, (SYM_TABLE.get(words[++index])));
                                mem_location += INT_SIZE;
                            } else {
                                System.out.println("Bad 2nd value in STB command on line : " + lineNumber);
                            }
                            break;
                        case "LDB":
                            if (matches(indirRegEx, words[index + 2])) {
                                bb.putInt(mem_location, INSTRUCTIONS.indexOf("LDB") + 1 + indirOptCodeOffset);
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, getReg(words[++index]));
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, getReg(words[++index]));
                                mem_location += INT_SIZE;
                            } else if (SYM_TABLE.containsKey(words[index + 2])) {
                                bb.putInt(mem_location, INSTRUCTIONS.indexOf("LDB") + 1);
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, getReg(words[++index]));
                                mem_location += INT_SIZE;
                                bb.putInt(mem_location, (SYM_TABLE.get(words[++index])));
                                mem_location += INT_SIZE;
                            } else {
                                System.out.println("Bad 2nd value in LDB command on line : " + lineNumber);
                            }
                            break;
                        case "TRP":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("TRP") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, Integer.parseInt(words[++index]));
                            mem_location += INT_SIZE;
                            mem_location += INT_SIZE;
                            break;
                        case "ADD":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("ADD") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            break;
                        case "ADI":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("ADI") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, Integer.parseInt(words[++index]));
                            mem_location += INT_SIZE;
                            break;
                        case "SUB":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("SUB") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            break;
                        case "MUL":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("MUL") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            break;
                        case "DIV":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("DIV") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            break;
                        case "CMP":
                            bb.putInt(mem_location, INSTRUCTIONS.indexOf("CMP") + 1);
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            bb.putInt(mem_location, getReg(words[++index]));
                            mem_location += INT_SIZE;
                            break;
                    }
                }
            }
            fileReader.close();
            passNumber++;
            REG[SL]=endProg; ///set stack limit
            lineNumber=0;
        }

        // *************************
        // Virtual Machine
        // *************************

        while (REG[PC] < endProg) {
            int instruction1 = bb.getInt(REG[PC]);   // get 1st int from instruction
            REG[PC] += INT_SIZE;

            int instruction2 = bb.getInt(REG[PC]);    // get 2nd int from instruction
            REG[PC] += INT_SIZE;

            int instruction3 = bb.getInt(REG[PC]);  //get 3rd int but might not be used;
            REG[PC] += INT_SIZE;

            switch (instruction1) {
                case 1:  //"JMP"
                    REG[PC] = instruction2;
                    break;
                case 2:  //"JMR"
                    REG[PC] = REG[instruction2];
                    break;
                case 3:  //"BNZ"
                    if (REG[instruction2] != 0)
                        REG[PC] = instruction3;
                    break;
                case 4:  //"BGT"
                    if (REG[instruction2] > 0)
                        REG[PC] = instruction3;
                    break;
                case 5:  //"BLT"
                    if (REG[instruction2] < 0)
                        REG[PC] = instruction3;
                    break;
                case 6:  //"BRZ"
                    if (REG[instruction2] == 0)
                        REG[PC] = instruction3;
                    break;
                case 7:  //"MOV"
                    REG[instruction2] = REG[instruction3];
                    break;
                case 8:  //"LDA"
                    REG[instruction2] -= REG[instruction2];
                    REG[instruction2] = instruction3;
                    break;
                case 9: //STR
                    bb.putInt(instruction3, REG[instruction2]);
                    break;
                case 10:  //"LDR"
                    REG[instruction2] -= REG[instruction2];
                    REG[instruction2] = bb.getInt(instruction3);
                    break;
                case 12:  //"LDB
                    REG[instruction2] -= REG[instruction2];
                    REG[instruction2] = (int) data[instruction3];
                    break;
                case 21: //"TRP":
                    switch (instruction2) {
                        case 0:
                            System.exit(0);
                            break;
                        case 1:
                            System.out.print(REG[3]);
                            break;
                        case 3:
                            System.out.print(Character.toString((char) REG[3]));
                            break;
                        case 4:
                            trap4();
                            break;
                    }
                    break;
                case 13: //"ADD":
                    REG[instruction2] += REG[instruction3];
                    break;
                case 14: //"ADI":
                    REG[instruction2] = REG[instruction2] + instruction3;
                    break;
                case 15: //"SUB":
                    REG[instruction2] -= REG[instruction3];
                    break;
                case 16: //"MUL":
                    REG[instruction2] *= REG[instruction3];
                    break;
                case 17:  //"DIV":
                    REG[instruction2] /= REG[instruction3];
                    break;
                case 20: //"CMP"
                    REG[instruction2] -= REG[instruction3];
                    break;
                case 22: //"STR indirect address"
                    bb.putInt(REG[instruction2], REG[instruction3]);
                    break;
                case 23: //"LDR indirect address"
                    REG[instruction2] -= REG[instruction2];
                    REG[instruction2] = (int) bb.getInt(REG[instruction3]);
                    break;
                case 24: //"STB indirect address"
                    bb.put(REG[instruction3], (byte) REG[instruction2]);
                    break;
                case 25: //"LDB indirect address"
                    REG[instruction2] = bb.get(REG[instruction3]);
                    break;
                default:
                    System.out.println("Instruction does not exit :" + instruction1);
            }
        }

    }

    static int getReg(String temp) {
        if (temp.equals("R0")) return 0;
        if (temp.equals("R1")) return 1;
        if (temp.equals("R2")) return 2;
        if (temp.equals("R3")) return 3;
        if (temp.equals("R4")) return 4;
        if (temp.equals("R5")) return 5;
        if (temp.equals("R6")) return 6;
        if (temp.equals("R7")) return 7;
        if (temp.equals("PC")) return 8;
        if (temp.equals("SL")) return 9;
        if (temp.equals("SP")) return 10;
        if (temp.equals("FP")) return 11;
        if (temp.equals("SB")) return 12;
        else return 13;
    }

    static boolean isDirective(String checkVal) {
        for (String i : DIRECTIVES) {
            if (checkVal.toUpperCase().equals(i))
                return true;
        }
        return false;
    }

    static boolean isLabel(String checkVal) {
        for (String i : INSTRUCTIONS) {
            if (checkVal.toUpperCase().equals(i))
                return false;
        }
        for (String i : DIRECTIVES) {
            if (checkVal.toUpperCase().equals(i))
                return false;
        }
        return true;
    }

    static boolean labelExist(String checkVal) {
        if (SYM_TABLE.containsKey(checkVal)) {
            return true;
        }
        return false;
    }

    static void addToSymbolTable(String[] line) {
        String label = line[0];
        String dir = line[1].toUpperCase();
        SYM_TABLE.put(label, mem_location);

    }
    private static void trap4(){

        //    inStack.clear();
        if(inStack.empty()){
            inStack.push('\n');
            Scanner inScanner =new Scanner(System.in);
            char [] inData = inScanner.nextLine().toCharArray();

            for(int c = (inData.length-1); c >= 0; --c ){
                inStack.push(inData[c]);
            }
            try {
                REG[3]= inStack.pop();
            }
            catch (EmptyStackException e){
                System.out.println("Empty Stack");
            }

        }
    }
}

