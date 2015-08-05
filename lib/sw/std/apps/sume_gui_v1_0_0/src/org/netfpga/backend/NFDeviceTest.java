package org.netfpga.backend;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Random;

import javax.swing.Timer;

public class NFDeviceTest extends NFDevice implements ActionListener{

    HashMap<Long, Integer> table;

    Timer timer;

    public NFDeviceTest(String ifaceName) {
        table = new HashMap<Long, Integer>();
        timer = new Timer(5000, this);
        timer.start();
    }

    /**
     * Read the register at the specified address
     * @param addr
     * @return the value at the address
     */
    public int readReg(long addr){
        Long key = new Long(addr);
        if(!table.containsKey(key)){
            table.put(key, new Integer(0));
        }
        int value = ((Integer)table.get(key)).intValue();
//        System.out.println("Read "+value+" from 0x"+ Long.toHexString(addr));
        return value;
    }

    /**
     * Write value to the speicifed address
     * @param addr the location to write
     * @param value the value to write
     * @return
     */
    public void writeReg(long addr, int value){
//        System.out.println("Wrote "+value+" to 0x"+ Long.toHexString(addr));
        Long key = new Long(addr);
        table.put(key, new Integer(value));
    }

    /**
     * Perform all opreations in the array in one go
     * @param addr the locations to read/write
     * @param value the values to read/write
     * @param access_types for each location, a 1 is a read, a 0 is a write
     * @param num_accesses the number of addresses in the array to read/write
     * @return
     * @return
     */
    public void accessRegArray(long []addr, int []value, int[] access_types, int num_accesses){
//        System.out.println("Accessing Reg array...");
        for(int i=0; i<num_accesses; i++){
            if(access_types[i]==WRITE_ACCESS){
                writeReg(addr[i], value[i]);
            } else {
                value[i] = readReg(addr[i]);
            }
        }
    }

    /**
     * check if the interface exists
     * @return 1 on error
     */
    public int checkIface(){
        return 0;
    }

    /**
     * Opens the interface for access
     * @return non-zero on error
     */
    public int openDescriptor(){
        return 0;
    }

    /**
     * Closes the file descriptor
     * @return non-zero on error
     */
    public int closeDescriptor(){
        return 0;
    }

    public void actionPerformed(ActionEvent e) {
        Collection<Long> keySet = table.keySet();
        Iterator<Long> i = keySet.iterator();
        Random r = new Random();
        while(i.hasNext()){
            /* flip a coin to determine if we should increment */
            boolean heads = r.nextBoolean();
            Long v=(Long)i.next();
            if(heads || r.nextBoolean()){
//                System.out.println("Updating value in 0x"+v);
                table.put(v, ((Integer)(((Integer)table.get(v)).intValue()+r.nextInt(100))));
            } else {
//                System.out.println("Not updating value in 0x"+v);
            }
        }
        /* make sure the number removed<number stored */
//        for(int j=0; j<4*5; j+=4){


            int addr_rem0 = NFDeviceConsts.SUME_OUTPUT_QUEUES_0_BYTESREMOVEDPORT0;//XPAR_NF10_BRAM_OUTPUT_QUEUES_0_BYTES_REMOVED_PORT_0+j;
            int addr_str0 = NFDeviceConsts.SUME_OUTPUT_QUEUES_0_BYTESSTOREDPORT0;//XPAR_NF10_BRAM_OUTPUT_QUEUES_0_BYTES_STORED_PORT_0+j;
            Integer val_rem0 = (Integer)table.get(addr_rem0);
            Integer val_str0 = (Integer)table.get(addr_str0);
            if(val_rem0 != null && val_str0 != null){
                if(val_rem0.intValue()>val_str0.intValue()){
                    Long addr0 = new Long(addr_str0);
                    table.put(addr0, val_rem0);
                }
            }



            int addr_rem1 = NFDeviceConsts.SUME_OUTPUT_QUEUES_0_BYTESREMOVEDPORT1;
            int addr_str1 = NFDeviceConsts.SUME_OUTPUT_QUEUES_0_BYTESSTOREDPORT1;
            Integer val_rem1 = (Integer)table.get(addr_rem1);
            Integer val_str1 = (Integer)table.get(addr_str1);
            if(val_rem1 != null && val_str1 != null){
                if(val_rem1.intValue()>val_str1.intValue()){
                    Long addr1 = new Long(addr_str1);
                    table.put(addr1, val_rem1);
                }
            }


            int addr_rem2 = NFDeviceConsts.SUME_OUTPUT_QUEUES_0_BYTESREMOVEDPORT2;
            int addr_str2 = NFDeviceConsts.SUME_OUTPUT_QUEUES_0_BYTESSTOREDPORT2;
            Integer val_rem2 = (Integer)table.get(addr_rem2);
            Integer val_str2 = (Integer)table.get(addr_str2);
            if(val_rem2 != null && val_str2 != null){
                if(val_rem2.intValue()>val_str2.intValue()){
                    Long addr2 = new Long(addr_str2);
                    table.put(addr2, val_rem2);
                }
            }



            int addr_rem3 = NFDeviceConsts.SUME_OUTPUT_QUEUES_0_BYTESREMOVEDPORT3;
            int addr_str3 = NFDeviceConsts.SUME_OUTPUT_QUEUES_0_BYTESSTOREDPORT3;
            Integer val_rem3 = (Integer)table.get(addr_rem3);
            Integer val_str3 = (Integer)table.get(addr_str3);
            if(val_rem3 != null && val_str3 != null){
                if(val_rem3.intValue()>val_str3.intValue()){
                    Long addr3 = new Long(addr_str3);
                    table.put(addr3, val_rem3);
                }
            }



            int addr_rem4 = NFDeviceConsts.SUME_OUTPUT_QUEUES_0_BYTESREMOVEDPORT4;
            int addr_str4 = NFDeviceConsts.SUME_OUTPUT_QUEUES_0_BYTESSTOREDPORT4;
            Integer val_rem4 = (Integer)table.get(addr_rem4);
            Integer val_str4 = (Integer)table.get(addr_str4);
            if(val_rem4 != null && val_str4 != null){
                if(val_rem4.intValue()>val_str4.intValue()){
                    Long addr4 = new Long(addr_str4);
                    table.put(addr4, val_rem4);
                }
            }





//        }
    }

}
