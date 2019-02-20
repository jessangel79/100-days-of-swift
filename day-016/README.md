# Day 16: Project 1, Part One

_Follow along at https://www.hackingwithswift.com/100/16_.


## 📒 Field Notes

This day represents the beginning of the projects in [Hacking with Swift](https://www.hackingwithswift.com/read).

I have a [separate repository](https://github.com/CypherPoet/book--hacking-with-swift) where I've been creating projects alongside the material in the book. And you can find Project 1 [here](https://github.com/CypherPoet/book--hacking-with-swift/tree/master/01-Storm-Viewer). However, this day focused specifically on a number of topics:

- Setting up Projects in Xcode
- Listing images with FileManager
- Designing our interface


### Setting up Projects in Xcode

Xcode's setup process is pretty straightforward, but the one thing that's probably important to note is the `Organization Identifier` setting. When publishing an app to the App Store, this will need to be unique. And so, there seems to be a well-established convention of making this your website domain name in reverse, followed by the name of the app. For example: `com.mysite`.


### Listing Images with FileManager

When we have a set of images that we want to load by directly specifying their paths, we can use a combination of `FileManager` and `Bundle`.

`Bundle.main.resourcePath` will compute the dynamically generated resource path that our assets will have when our app is running on a device, and an instance of `FileManager.default` can use that path, treat it as a directory, and fetch the directory's contents.

```swift
  let fm = FileManager.default
  let path = Bundle.main.resourcePath!

  let images = try! fm.contentsOfDirectory(atPath: path)

  imagePaths = images.filter({ $0.hasPrefix("nssl") })
```

I'm curious about image-loading strategies that involve [storing images as assets catalogs](https://stackoverflow.com/questions/38117076/asset-catalog-vs-folder-reference-when-to-use-one-or-the-other) &mdash; but regardless, this was a nice example of using `FileManager` and `Bundle` in tandem.

### Designing our Interface

This section covered using `UITableViewController` creating a table for our images &mdash; feeding it with the image data we generated by finding our app's image names.

It touched on overriding a few functions that seem to be staples of `UITableViewController`:

- `tableView(_:cellForRowAt:)`
- `tableView(_:didSelectRowAt:)`
- `tableView(_:numberOfRowsInSection:)`

Whenever we're using an array of data to drive a section, `numberOfRowsInSection` can make use of its count property:

```swift
override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return imagePaths.count
}
```

`cellForRowAt` can make use of an _extremely_ important performance optimization: dequeing  reusable cells (AKA recycling views). This means that the OS can store cells as a queue in memory, and then pull from one end or the other as the user scrolls through the list. This prevents the app from potentially creating an astronomical number of unique cells.

```swift
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)

    cell.textLabel?.text = imagePaths[indexPath.row]

    return cell
}
```

Smashing Magazine recently had a [good article](https://www.smashingmagazine.com/2019/02/ios-performance-tricks-apps/) that mentioned this and other handy performance techniques.


## 🔗 Related Links

- [Apple Docs: Prepare for App Distribution](https://help.apple.com/xcode/mac/current/#/dev91fe7130a)
- [Smashing Magazine: iOS Performance Tricks To Make Your App Feel More Performant](https://www.smashingmagazine.com/2019/02/ios-performance-tricks-apps/)