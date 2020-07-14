# assignment-two-swift
*I do not have access to the assignment breif that I did for this assignment, which was "Artworks on Campus".
However, this years assignment (attached below) follows a similar basis.*

https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/assignments/COMP228%20Assignment%202.pdf


## Developing a “Coffee-Shops on Campus” App.
### Your Task:
You will design and develop an application written in Swift 5 (or later) for iPhone 8. The application will enable you to locate
coffee-shops on campus relative to the user’s current location.
In order to do this, you will need to retrieve data from a web service regarding the location of, and information about,
coffee-shops on campus (note the underscore character that precedes the word “ajax” in the following URL).
https://dentistry.liverpool.ac.uk/_ajax/coffee/
This URL will return information about the full set of coffee-shops that are recorded in the database. To retrieve information
on a specific shop, use the URL below (supplying the appropriate value for the ID)
https://dentistry.liverpool.ac.uk/_ajax/coffee/info/?id=1
Note:
1. Use secure URLs, otherwise your app will not load the data or images.
2. Although the database structure will remain the same, the content will be updated soon to include URLs for
images of the coffee-shops (at the moment, those image URLs are all null).
Your application is required to have the following basic features **(worth 70%):**
1. The user is initially presented with a map centred on their current location and at a reasonable level of
zoom so that nearby roads etc. can be seen clearly. You may assume that the user is currently in the
Ashton Building (a location file is available for Xcode to simulate the location of the Ashton Building).
(latitude: 53.406566, longitude: -2.966531). **(worth 20%)**
2. Retrieve and decode the JSON data from the URLs, using the Codable protocol and JSONDecoder() (See
lecture set 3, slides 19-22). **(worth 10%)**
3. The map contains a number of annotation marks indicating the location of nearby coffee-shops. (worth 5%)
4. In portrait view, a table below the map contains a list of coffee-shops (along with basic information), ordered by
distance from the current location. **(worth 20%)**
5. Tapping on an annotation displays more detailed information about a specific coffee-shop, including an image
(where available) and opening times, contact details, address etc. **(worth 15%)**

**25%** of the marks may be obtained by implementing useful features such as:
1. A search box allows the user to filter the items displayed in the table. **(worth 5%)**
2. Caching the coffee-shop information (in Core Data) on first run of the app. On subsequent runs, if no data
connection is available, retrieve and display the information from Core Data. **(worth 10%)**
3. Implement an alternative layout in landscape view, e.g. the map displayed on the left and the table of coffee-shops
displayed on the right. **(worth 10%)**
Please ensure that your code is appropriately commented and meaningful class, variable and constant names are used
**worth 5%).**
If you use any additional images or other materials, ensure that these are copied into the project – not just referenced
somewhere else in your filestore. The zipped folder that you submit should include everything required to compile and run
your App.
Important - Please note:
Do not use any third party frameworks in your App (e.g. Alamofire). Use Apple standard frameworks ONLY. Using a nonstandard framework will incur a penalty of 20%.
What to Submit
Your completed project should be zipped up and submitted via the online submission system:
https://sam.csc.liv.ac.uk/COMP/Submissions.pl
(In the Finder, right click the icon for the folder containing the project file and folder and choose “Compress”)
Also submit a short document (maximum of 1-2 sides of A4) documenting how to use your app and any notable features
or limitations.
Deadline for submission: Friday December 6th at 17:00.
Reminder: This is the second of two assignments, each of which is worth 15% of the total mark for COMP228/327. Your
portfolio of lab work will be worth another 10%.
