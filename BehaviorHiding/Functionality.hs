module BehaviorHiding.Functionality(performInit,
performClone, 
performAdd, 
performRemove, 
performStatus, 
performHeads, 
performDiff, 
performLog, 
performCheckout, 
performCommit,
performCat,
performPull,
performPush) where

import System.Directory (doesDirectoryExist, getCurrentDirectory, doesFileExist, doesPathExist, listDirectory)
import System.Environment
import System.Process
import Data.List

import SoftwareDecision.Concept.TrackedSet (addFile, removeFile, getTrackedSet)
import SoftwareDecision.Concept.Repo (createRepo)


performInit :: IO String
performInit = do
   doesExist <- doesDirectoryExist "./.dvcs"
   cd <- getCurrentDirectory
   if doesExist then return ("Reinitialized existing dvcs repository in " ++ cd)
   else do
      createRepo
      -- create root commit
      return "Initialized repo"

------------------------------------
performClone :: String -> IO String
performClone repo_path = do
   isLocalPath <- doesPathExist repo_path
   if isLocalPath then do
     _ <- readProcess "cp" ["-r", repo_path, "."] ""
     return "Cloned local repo"
   else do
     _ <- readProcess "scp" ["-r", repo_path, "."] ""
     return "Cloned remote repo"

------------------------------------
performAdd :: String -> IO String
performAdd file = do
   doesExist <- doesDirectoryExist "./.dvcs"
   if not(doesExist) then return "fatal: not a dvcs repository .dvcs"
   else do
     inCD <- doesFileExist file
     trackedFiles <- getTrackedSet
     if not(inCD) then do
       if (file `notElem` trackedFiles) then return "fatal: File does not exist in CD" 
       else do
         removeFile file
         return "File removed as its not in CD"  
     else do
       addFile file
       return "File added"

------------------------------------
performRemove :: String -> IO String
performRemove file = do
   doesExist <- doesDirectoryExist "./.dvcs"
   if not(doesExist) then return "fatal: not a dvcs repository .dvcs"
   else do
     trackedFiles <- getTrackedSet
     if (file `notElem` trackedFiles) then return "Error: File not being tracked. Nothing to remove"
     else do
         removeFile file
         return "File removed"

------------------------------------
performStatus :: IO String
performStatus = do 
   trackedFiles <- getTrackedSet
   putStrLn "Tracked files:"
   Prelude.mapM_ putStrLn trackedFiles
   putStrLn "\nUntracked files:"   
   allFiles <- listDirectory "."
   Prelude.mapM_ putStrLn (allFiles \\ trackedFiles)
   return "\ndvcs status output"

-- TODO --
------------------------------------
performHeads :: IO String
performHeads = do return "dvcs heads output"

performDiff :: String -> String -> IO String
performDiff revid1 revid2 = do return "dvcs diff output"

performLog :: IO String
performLog = do return "dvcs log output"

performCheckout :: String -> IO String
performCheckout revid = do return "Checked out"

performCommit :: String -> IO String
performCommit msg = do return "Committed"

performCat :: String -> String -> IO String
performCat revid file = do return "dvcs cat output"

performPull :: String -> IO String
performPull repo_path = do return "Pulled"

performPush :: String -> IO String
performPush repo_path = return "Pushed"
