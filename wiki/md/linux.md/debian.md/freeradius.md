#### Free RADIUS
-----------------

1. ##### Dictinary
    
    1. *What is that?*
    
        Unlike text-based protocols such as SMTP or HTTP, RADIUS is a binary protocol; therefore, although attributes are commonly referred to by name (for example, "User-Name"), these names have no meaning in the protocol. Data (i.e., "User-Name") are encoded in a message as a binary header with binary data, and not as text strings.

        Dictionary files are used to map between the names used by people and the binary data in the RADIUS packets. FreeRADIUS ships with over 100 dictionaries, totalling nearly 5000 attribute definitions. These dictionaries are used to simplify the configuration of the server and to   allow easy extensibility without source code compilation.
        The server uses the dictionaries to interpret the binary data as follows: the server searches the dictionaries to match the number from the packet, and the corresponding data type in the dictionary entry is then used by the server to interpret the binary data in the packet. The name within the dictionary entry appears in all logs and debug messages, in order to present the attribute in a form that is understandable to people.
        This process also works in reverse: the server uses the dictionaries to encode a string (i.e., "User-Name = Bob") as "number, length, binary data" in a packet.
        
        Note that there is no direct connection between the NAS and the dictionary files, as the dictionary files reside only on the server. For example, if names are edited in a local dictionary file, there is no effect on any other NAS or RADIUS server, because these names appear only in the local dictionary file. The RADIUS packets remain in binary format and contain only numbers, not names.

        **Major reasons**
        
        The primary purpose of the dictionaries is to map descriptive names to attribute numbers in a packet. For efficiency reasons, each packet contains an "encoded" version of an attribute. The encoded version is binary data and is not readable, unlike a string (such as User-Name = "bob"). The encoded version cannot be used in the server policies, so descriptive names are used instead.
        
        The dictionaries secondary function is to define data types for an attribute. As with the names, the data types are not encoded in a packet. Instead, the types are stored in a dictionary on the server. When the server needs to determine how to encode a User-Name, it looks up that information in a dictionary. When the server needs to decode an attribute from a packet, it looks up that information in the dictionary as well, for example, to determine that the attribute should be interpreted as a User-Name of type string.
        
        Finally, the dictionaries provide for easy extension of the protocol. New attributes can be defined in a dictionary without changing any of the source code of a server or a client. These attributes can then be used as part of a policy decision or logged as part of an accounting record. This capability lets equipment vendors define new functionality for their equipment by publishing a dictionary file. For example, if a server does not support an NAS, in many cases support may be added by writing the correct dictionary file for that NAS.

    2. *Compatibility*
    
        The dictionary files format is **not standardized** across RADIUS servers. While there may be similarities from one server to another, they cannot, in general, be copied "as is" from one RADIUS server to another.
        It is very important to use the correct dictionaries. If the wrong dictionaries are used, the server may not properly interpret local configuration, or generate the correct response for the NAS.The format of the RADIUS dictionary files is not currently standardized, although most are simple variants of the original Livingston format defined in 1992. Because of the differences in format, a server’s dictionary files may be incompatible with different versions of the same RADIUS server software; one server’s dictionary files can also be incompatible with another server’s dictionary files.

    3. *File format* 
    
        File format of dictionaries is not standardized (differs from a server to another server).
        Define an attribute:
        **ATTRIBUTE attribute-name number type**
        Define the attribute value:
        **VALUE attribute-name value-name number**
        an so on.

        To maintain backward compatibility, the dictionaries distributed with FreeRADIUS often define multiple names for the same attribute number. The reason for this repetition is that some attributes have been re-named as later RFCs obsolete earlier ones, and the old names may still be used in some configuration files. This multiple definition leads us to explain some of the additional validation and usage rules surrounding dictionaries.

        >[See more](https://networkradius.com/doc/current/concepts/dictionary/introduction.html)

2. ##### Installation 

    Packages:
    - libauthen-radius-perl +
    - libauthen-simple-radius-perl + 
    - libgcrypt11-dev +  
    - wget +
    - build-essential + 
    - freeradius + 
    - freeradius-mysql +
    -  mysql-server + 

>[!Notes]
>1. [Setup FreeRadius] (based on https://linuxscriptshub.com/setup-radius-server-ubuntu-1604/ 
Distributive: debian-9.5.0 x64