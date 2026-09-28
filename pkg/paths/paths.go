package paths

import (
	"os"
	"path/filepath"
	"runtime"
)

func ExeDir() string {
	exe, err := os.Executable()
	if err != nil {
		wd, _ := os.Getwd()
		return wd
	}
	return filepath.Dir(exe)
}

// DataDir returns the writable directory used for databases and exports.
// A macOS app bundle must not modify its own Contents directory, so macOS
// stores runtime data in the standard per-user Application Support directory.
func DataDir() string {
	if runtime.GOOS == "darwin" {
		if configDir, err := os.UserConfigDir(); err == nil {
			return filepath.Join(configDir, "qzone-history")
		}
	}
	return ExeDir()
}

func UserDir(qq string) string {
	return filepath.Join(DataDir(), qq)
}

func EnsureUserDir(qq string) (string, error) {
	dir := UserDir(qq)
	return dir, os.MkdirAll(dir, 0755)
}

func UserDBPath(qq string) string {
	return filepath.Join(UserDir(qq), "app.db")
}

func ExportJSONPath(qq string) string {
	return filepath.Join(UserDir(qq), qq+"_export.json")
}

func ActivitiesJSONPath(qq string) string {
	return filepath.Join(UserDir(qq), qq+"_activities.json")
}

func ViewerHTMLPath(qq string) string {
	return filepath.Join(UserDir(qq), qq+"_view.html")
}
