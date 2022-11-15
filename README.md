<div align="center">

  ![EPS 2 Image](./.github/workflows/logo.png)

  ### *An action to convert `.eps` (Encapsulated PostScript) files to image formats and vector formats.*

</div>


***Supported output formats***
- **Image formats (*raster*)**
  - `.png` ***\* default***
  - `.bmp`
  - `.tiff`
  - `.jpeg`

- **Vector formats**
  - `.svg`
  - `.pdf`

## Usage
### Inputs
```yaml
input:
  description: Input path of the EPS file.
  required: true
output:
  description: Output path of the image file.
  required: false
format:
  description: Format of the image file.
  required: false
  default: png
```

### Outputs
&emsp;Images exist only in the workflow, so you will need another action to commit or upload the generated images.

---
### Available options
```yaml
- uses: lunatic-fox/eps2img@v1
  with:
    # Required. Full relative path to EPS file.
    input: ./pathToEPS/file.eps

    # Optional. Path to the output file.
    # Patterns: "", "./", "./dirname/", "./filename", "./filename.xyz"
    output: ./pathTo/output-file

    # Optional. Format of the output file.
    # Options: "png", "bmp", "tiff", "jpeg", "svg", "pdf"
    format: png
```
---

#### `input`
&emsp;This input parameter is required and is the full relative path to your `.eps` file.

***Example***
```yaml
input: ./folder/myFile.eps
```
---
#### `output`
&emsp;This input parameter is optional and can be used as shown in the patterns below.

***Example: If `output` does not exist***\
&emsp;Creates the output file in the same path and with the same filename of the `.eps` file.
```yaml
input: ./folder/myFile.eps
# generates -> output: ./folder/myFile.png 
```

***Example: Is a complete path***\
&emsp;Creates the output file in the described path.
```yaml
input: ./folder/myFile.eps
output: ./myConvertedFile.png 
```

***Example: Is an incomplete path***\
&emsp;Creates the output file in the same path until the last `/` and uses the end of path as the filename.
```yaml
input: ./folder/myFile.eps
output: ./screenshot/myPicture
# generates -> output: ./screenshot/myPicture.png 
```

***Example: Is an endpoint***\
&emsp;Creates the output file in the described path and names the file with the same filename of the `.eps` file.
```yaml
input: ./folder/myFile.eps
output: ./screenshot/
# generates -> output: ./screenshot/myFile.png 
```
---
#### `format`
&emsp;This input parameter is optional and `output` have priority over it.

***Example: If `output` is a complete path***\
&emsp;Creates the output file in the described path. `format` will be ignored.
```yaml
input: ./folder/myFile.eps
output: ./myConvertedFile.png
format: tiff
```

***Example: If `output` is an incomplete path***\
&emsp;Creates the output file in the same path until the last `/`, uses the end of path as the filename and convert the `.eps` file to defined `format`.
```yaml
input: ./folder/myFile.eps
output: ./screenshot/myPicture
format: jpeg
# generates -> output: ./screenshot/myPicture.jpeg
```

***Example: If `output` is an endpoint***\
&emsp;Creates the output file in the described path, names the file with the same name of the `.eps` file and convert the `.eps` file to defined `format`.
```yaml
input: ./folder/myFile.eps
output: ./screenshot/
format: bmp
# generates -> output: ./screenshot/myFile.bmp 
```

***Example: If `output` does not exist***\
&emsp;Creates the output file in the same path, with the same filename of the `.eps` file and convert the file to defined `format`.
```yaml
input: ./folder/myFile.eps
format: pdf
# generates -> output: ./folder/myFile.pdf
```

<div align="center">

  ### [Workflow example](./.github/workflows/demo.yml)

  Made with ❤
</div>
