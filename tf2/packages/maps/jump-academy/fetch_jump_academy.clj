(ns fetch-jump-academy
  (:require [babashka.fs :as fs]
            [babashka.process :as p]
            [babashka.http-client :as http]
            [cheshire.core :as json]
            [clojure.tools.logging :as l]
            [clojure.string :as str]
            [clojure.java.io :as io]
            [clojure.edn :as edn]))

(def ^:dynamic *dry-run?* true)

(def cache-dir (fs/xdg-cache-home "fetch-jump-academy"))

(def maps-cache-dir (fs/file cache-dir "maps"))

(defn list-maps []
  (let [map-list-file (fs/file cache-dir "map-list.edn")]
    (fs/create-dirs cache-dir)
    (if (fs/exists? map-list-file)
      (with-open [r (io/reader map-list-file)]
        (edn/read (java.io.PushbackReader. r)))
      (if *dry-run?*
        (throw (ex-info (str "Cannot list maps during a dry run "
                             "unless previous result is cached.")
                        {}))
        (let [resp (http/post
                    "https://cdn.jumpacademy.tf/?generate"
                    {:headers {:content-type "application/x-www-form-urlencoded"}
                     :body (slurp "./request")})]
          (if (= (:status resp) 200)
            (as-> (:body resp)
                $
              (str/replace $ "wget " "")
              (str/split $ #"[\n\r]")
              (pr-str $)
              (spit map-list-file $))
            (throw (ex-info "Bad response from jumpacademny.tf" resp))))))))

(defmacro race [x y]
  `(let [p# (promise)
         f1# (future (deliver p# ~x))
         f2# (future (deliver p# ~y))
         winner# @p#]
     (future-cancel f1#)
     (future-cancel f2#)
     winner#))

(defn prefetch [url]
  (let [command ["nix store prefetch-file --json" url]]
    (if *dry-run?*
      (do (apply println "$" command)
          "«hash»")
      (when-some [data
                  (race (apply p/shell {:out :string} command)
                        (do (Thread/sleep (* 120 1000))
                            (binding [*out* *err*]
                              (l/warnf "Timed out whilst prefetching %s" url))
                            nil))]
        (-> data :out (json/decode keyword) :hash)))))

(defn prefetch*
  "A caching variant of `prefetch`."
  [url]
  (let [[_ file-name] (re-find #"/([^/]*)$" url)
        cache-entry (fs/file maps-cache-dir (str file-name ".hash"))]
    (if (fs/exists? cache-entry)
      (let [cached-result (slurp cache-entry)]
        cached-result)
      (let [hash (prefetch url)]
        (when (and hash
                   ;; During dry runs, `prefetch` will return fake hashes that
                   ;; we don't want to pollute the cache with.
                   (not *dry-run?*))
          (fs/create-dirs (fs/parent cache-entry))
          (spit cache-entry hash))
        hash))))

(defn fetch-map
  "Construct a map with the necessary info to package a map from JumpAcademy.
  `name` is expected to be the package's name.  URL is the map's CDN URL on
  JumpAcademy.  Returns nil on failure."
  [name url]
  (binding [*out* *err*]
    (l/infof "Fetching %s" name))
  (when-some [hash (prefetch* url)]
    {:description (format "Map %s for TF2" name)
     ;; For forward-compatibility, when we hopefully add support those
     ;; pesky non-GitHub downloads.
     :src {:__type "zip"
           :url url
           :hash hash}}))

(defn parse-map-name [url]
  (let [[_ name] (re-find #"/([^/]*)\.bsp\.bz2$" url)]
    name))

(defn fetch-jump-academy []
  (into {}
        (for [map-url (list-maps)]
          (let [map-name (parse-map-name map-url)]
            (if-some [map-info (fetch-map map-name map-url)]
              [(keyword map-name)
               map-info]
              (binding [*out* *err*]
                (l/warnf "Skipping map `%s`" map-name)
                nil))))))

(defn -main []
  (binding [*dry-run?* false]
    (-> (fetch-jump-academy)
        json/encode
        print)))
