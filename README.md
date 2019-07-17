# download_manager

A package for automatically downloading and storing files

## Getting Started


### Creating a DownloadableFile

The first step is to create a downloadable file. The simplest way to do this is using a SimpleDownloadableFile

E.g. you can create one with a function (returning something can be written to file) 

```
  File testFile = File("test_file.txt");
  var downloadFile = DownloadableFileBasic(() => "Test string", testFile);
```

You can also, optionally, set an expiry date time to your DownloadableFileBasic class. The purpose of this is 
to have a file which is only downloaded if the expiry date on the file is newer than the one you've already downloaded

