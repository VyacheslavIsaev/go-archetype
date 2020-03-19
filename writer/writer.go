package writer

import (
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/pkg/errors"

	"github.com/rantav/go-archetype/log"
	"github.com/rantav/go-archetype/types"
)

func WriteFile(destinationBase string, file types.File, mode os.FileMode) error {
	if file.Discarded {
		log.Debugf("File is discarded, not writing: %s", file.RelativePath)
		return nil
	}
	destinationPath := filepath.Join(destinationBase, file.RelativePath)
	log.Infof("Writing file %s", destinationPath)
	dir := filepath.Dir(destinationPath)
	err := os.MkdirAll(dir, os.ModeDir|os.ModePerm)
	if err != nil {
		return errors.Wrap(err, "error creating base dir for file")
	}
	err = ioutil.WriteFile(destinationPath, []byte(file.Contents), mode)
	return errors.Wrap(err, "error writing file")
}
