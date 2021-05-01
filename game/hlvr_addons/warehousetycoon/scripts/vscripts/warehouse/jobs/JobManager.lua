local JobManager = {
    Jobs = {};
    JobID = 1;
}

function JobManager:AddJob(job)
    JobManager.JobID = JobManager.JobID+1
    job.id = JobManager.JobID
    JobManager.Jobs[JobManager.JobID] = job
end

function JobManager:RemoveJob(job)
    JobManager.Jobs[job.id] = nil
end


return JobManager