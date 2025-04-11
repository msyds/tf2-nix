(ns fetch-hud-db
  (:require [babashka.fs :as fs]
            [babashka.process :as p]
            [cheshire.core :as json]
            [clojure.tools.logging :as l]
            [clojure.string :as str]))

(def hud-db-root (or (System/getenv "HUD_DB_ROOT")
                     (fs/expand-home "~/git/hud-db")))

(def ^:dynamic *dry-run?* true)

(defmacro race [x y]
  `(let [p# (promise)
         f1# (future (deliver p# ~x))
         f2# (future (deliver p# ~y))
         winner# @p#]
     (future-cancel f1#)
     (future-cancel f2#)
     winner#))

;; Hud-db only tracks GitHub repos.
(defn prefetch
  "Prefetch a Git repo and return the Nix SRI hash."
  [url rev]
  (let [command ["nix-prefetch-git"
                 "--quiet"
                 "--url" url
                 "--rev" rev]]
    (if *dry-run?*
      (do (apply println "$" command)
          "«hash»")
      (when-some [data (race (apply p/shell {:out :string} command)
                             (do (Thread/sleep (* 60 1000))
                                 (binding [*out* *err*]
                                   (l/warnf "Timed out whilst fetching %s" url))
                                 nil))]
        (-> data :out (json/decode keyword) :hash)))))

(defn parse-github-url [url]
  (when-some [[_ owner repo]
              ;; Not the most correct way to do this.
              (re-find #"github\.com/([^/]+)/([^/]+)$" url)]
    {:owner owner :repo repo}))

(def cache-dir (fs/xdg-cache-home "fetch-hud-db"))

(def huds-cache-dir (fs/file cache-dir "huds"))

(defn prefetch*
  "A caching variant of `prefetch`."
  [owner repo url rev]
  (let [name (str owner "###" repo)
        cache-entry (fs/file huds-cache-dir name rev)]
    (if (fs/exists? cache-entry)
      (let [cached-result (slurp cache-entry)]
        (if (empty? cached-result)
          nil
          cached-result))
      (let [hash (prefetch url rev)]
        (when (and hash
                   ;; During dry runs, `prefetch` will return fake hashes that
                   ;; we don't want to pollute the cache with.
                   (not *dry-run?*))
          (fs/create-dirs (fs/parent cache-entry))
          (spit cache-entry hash))
        hash))))

(defn fetch-hud
  "Construct a map with the necessary info to package a HUD from Hud-db.  `name`
  is expected to be the package's name, while `data` is a map parsed from
  Hud-db's JSON data files.  At the moment, only huds associated with GitHub
  repos are supported.  Returns nil on failure."
  [name data]
  (binding [*out* *err*]
    (l/infof "Fetching %s" name))
  (let [url (:repo data)]
    (when-some [{:keys [owner repo]} (parse-github-url url)]
      (let [;; N.B. hud-db uses 'hash' to refer to the Git revision hash, while
            ;; we use it to mean the Nix SRI hash.
            rev (:hash data)]
        (when-some [hash (prefetch* owner repo url rev)]
          {:description (format "%s for TF2, by %s" (:name data) (:author data))
           ;; For forward-compatibility, when we hopefully add support those
           ;; pesky non-GitHub downloads.
           :src {:__type "github"
                 :owner owner
                 :repo repo
                 :rev rev
                 :hash hash}})))))

(defn fetch-hud-db
  "Fetch each HUD from the data files `hud-db-root`/hud-data/*.json and return
  a map of each HUD."
  []
  (into {}
        (for [hud-data-path (fs/glob (fs/path hud-db-root "hud-data") "*.json")]
          (let [hud-name (-> hud-data-path fs/file-name fs/strip-ext)
                hud-data (-> hud-data-path fs/file slurp (json/decode keyword))]
            ;; See the docstring on `broken-huds`.
            (if-some [hud (fetch-hud hud-name hud-data)]
              [(keyword hud-name)
               hud]
              (binding [*out* *err*]
                (l/warnf "Skipping HUD `%s`" hud-name )
                nil))))))

(defn -main []
  (binding [*dry-run?* false]
    (-> (fetch-hud-db)
        json/encode
        print)))
