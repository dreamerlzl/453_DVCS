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

import System.Directory (doesDirectoryExist, getCurrentDirectory, doesFileExist, doesPathExist, listDirectory, copyFile)
import System.Environment
import System.Process
import Data.List

import SoftwareDecision.Concept.Commit (createCommitDir, getCommitFile, commitPath, CommitID(..))
import SoftwareDecision.Concept.TrackedSet (addFile, removeFile, getTrackedSet, cleanTrackedSet)
import SoftwareDecision.Concept.Repo
import SoftwareDecision.Concept.MetaOrganization (dvcsPath)
import SoftwareDecision.Utility.DvcsInterface
import SoftwareDecision.Communication

performInit :: IO String
performInit = do
   doesRepoAlreadyExist <- isRepo
   cd <- getCurrentDirectory
   if doesRepoAlreadyExist then return ("Reinitialized existing dvcs repository in " ++ cd)
   else do
      createRepo
      -- create root commit
      return "Initialized repo"

------------------------------------
performClone :: String -> IO String
performClone repoPath = do
   isLocalPath <- doesPathExist repoPath
   if isLocalPath then do
     doesRepoExist <- doesDirectoryExist $ repoPath ++ "/" ++ dvcsPath 
     if doesRepoExist then do
        copyDir repoPath "."
        return "Cloned local repo"
     else return "Local directory doesn't seen to be valid repository"
   else do
     let (hostname, remoteRepo) = break (==':') repoPath
     doesRepoExist <- doesRemoteDirExist hostname ((tail remoteRepo) ++ "/" ++ dvcsPath)
     if doesRepoExist then do
        downloadRemoteDir repoPath
        return "Cloned remote repo"
     else return "Remote directory doesn't seen to be valid repository"

------------------------------------
performAdd :: String -> IO String
performAdd file = do
   doesExist <- isRepo
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
   doesExist <- isRepo
   if not(doesExist) then return "fatal: not a dvcs repository .dvcs"
   else do
     trackedFiles <- getTrackedSet
     if (file `notElem` trackedFiles) then return "Error: File not being tracked. Nothing to remove"
     else do
         removeFile file
         return $ file ++ " removed"

------------------------------------
performStatus :: IO String
performStatus = do
   doesExist <- isRepo
   if not(doesExist) then return "fatal: not a dvcs repository .dvcs"
   else do 
   trackedFiles <- getTrackedSet
   putStrLn "Tracked files:"
   Prelude.mapM_ putStrLn trackedFiles
   putStrLn "\nUntracked files:"   
   allFiles <- listDirectory "."
   Prelude.mapM_ putStrLn (allFiles \\ trackedFiles)
   return "success" 


performCommit :: String -> IO String
performCommit msg = do 
  trackedFiles <- getTrackedSet
  
  if (length trackedFiles) == 0
    then return "Nothing to commit: tracked set empty"
    else do
      cleanTrackedSet -- remove files from TS if not in CD
      head_cid <- getHEAD
      -- putStrLn(getStr head_cid) -- print out HEAD

      if (getStr head_cid) == "root"
        then do
          -- This is the first (root) commit in repo
          commit_id <- createCommitDir msg
          let commit_path = (commitPath commit_id)
          putStrLn ("commit path: " ++ commit_path)

          -- Copy files
          mapM_ (\x -> copyFile (x) (commit_path ++ "/" ++ x)) trackedFiles

          setHEAD commit_id
          return "committed"
        
        else do
          -- TODO
          putStrLn "else"
          return "committed"

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

performCat :: String -> String -> IO String
performCat revid file = do return "dvcs cat output"

performPull :: String -> IO String
performPull repo_path = do return "Pulled"

performPush :: String -> IO String
performPush repo_path = return "Pushed"

