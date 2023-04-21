# Database creation

The aim of the two code routines in this folder is to search for all the Radiometric Coefficient files (RC files) in some default or specified folder, open them, and extract all the data that they contain in order to store them into a structure array. An example of a RC file is shown in appendix A from Merusi et al. (2022).

The file <i>cal_mars2020_struct.pro</i> is a routine that receives a list of RC filepaths in input, read all of them one by one, and write all their data in a structure array, where each element contains a single RC file. Eventually, the routine returns the complete filled array.

The file <i>make_ct_database.pro</i> is the main routine that is called by the user to create the structure. The routine can receive a path or a sol range in input, and it searches recursively for all the RC files inside that path. The list of RC files is passed to <i>cal_mars2020_struct.pro</i>, and the final structure is returned to the user.

## Way of use

The routine that is called is <i>make_ct_database.pro</i>. If it is called without any input parameter, such as:<br>

```
result = make_ct_database()
```

the routine will search for all the RC files in the default directory and all its subdirectories. The default directory is contained within the remote Mastcam-Z server hosted by ASU (Arizona State University). The variable <code>result</code> will contain the resulting database structure.

<b>NB:</b> The complete list of data of each element of the structure (in the forms of numbers, strings and arrays) is reported in the explanatory preamble of the file <i>cal_mars2020_struct.pro</i>.

If the user wants to search into another directory (for example, <code>/folder1/folder2/</code>), the syntax is:

```
result = make_ct_database(RC_FP = "/folder1/folder2/")
```

In addition, the user can also restrict the field to a limited range of sols. This parameter can be used alone (which means that the routine will search for all RC files from that sol range within the default path), for example:

```
result = make_ct_database(SOLS = [100:150])
```

or in combination with a specific path:

```
result = make_ct_database(RC_FP = "/folder1/folder2/", SOLS = [100:150])
```

In any of the cases shown above, the routine will create the structure (in the examples above, it's called <code>result</code>) and print on screen the number of RC files found, a list of files from sols that were not found, and a confirmation message if everything went without errors.<br>
Eventually, the structure can be handled as a normal IDL structure, and/or be saved as a SAVE file:

```
SAVE, result, FILENAME="savefile.sav"
```

and it can be loaded in any session of IDL by running the command:

```
RESTORE, "savefile.sav"
```
