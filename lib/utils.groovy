def save_output(input_ch, sub_dir_name) {
    input_ch.map { item ->
        def (meta, files) = (item instanceof List && item.size() == 2) ? [item[0], item[1]] : [null, item]
        def outDir = file("${params.outdir}/${sub_dir_name}")
        outDir.mkdir()

        // files is a list
        if (files instanceof List) {
            files.each { inputFile ->
               file(inputFile).copyTo(file("${outDir}/${file(inputFile).getName()}"))
            }
        } else {
            file(files).copyTo(file("${outDir}/${file(files).getName()}"))
        }
    }
}

def samplesheetToMetadata(input) {
    def rows = []
    input.withReader { reader ->
        def headers = reader.readLine().split(',').collect { it.trim() }
        reader.eachLine { line ->
            def values = line.split(',').collect { it.trim() }
            def row = [:]
            headers.eachWithIndex { h, i -> row[h] = values[i] }
            rows << row
        }
    }

    def isNumeric = { str ->
        str ==~ /^-?\d+(\.\d+)?$/
    }

    // Check types for each column
    def columnTypes = [:]
    if (rows) {
        def headers = rows[0].keySet()
        headers.each { col ->
            def values = rows.collect { it[col] }
            def allNumeric = values.every { v -> isNumeric(v) }
            def allString = values.every { v -> v instanceof String && !isNumeric(v) }
            columnTypes[col] = allNumeric ? 'numeric' : (allString ? 'string' : 'mixed')
        }
    }

    return [rows]
}

def ensureDir(String dirPath) {
    def dir = file(dirPath)
    if (!dir.exists()) {
        dir.mkdirs()
    }
    return Channel.fromPath(dirPath)
}

def paramsMap(params) {
    def yaml = new org.yaml.snakeyaml.Yaml()
    def param_map = params.collect { k, v ->
        def valueString = v.toString().replaceAll('[\\n\\r]', ' ')
        [k, valueString]
    }.collectEntries { pair -> 
        def key = pair[0]
        def val = pair[1]
        [key, val.toString()]
    }
    return(yaml.dumpAsMap(param_map).trim())
}